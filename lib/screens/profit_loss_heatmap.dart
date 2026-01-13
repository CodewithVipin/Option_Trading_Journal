// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:heat_map/model/trading_record.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ProfitLossHeatmap extends StatelessWidget {
  final Function(dynamic hiveKey) onDelete;
  final List<TradingRecord> records;
  final List<dynamic> keys;

  const ProfitLossHeatmap({
    super.key,
    required this.records,
    required this.keys,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final hiveKey = keys[index];

        final percent = record.investment == 0
            ? 0.0
            : (record.profitOrLoss / record.investment) * 100;

        final bool isProfit = record.profitOrLoss >= 0;

        final Color baseColor = isProfit
            ? Colors.greenAccent
            : Colors.redAccent;

        return GestureDetector(
          onTap: () => _showDetailsDialog(context, record, hiveKey, percent),

          child: Container(
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: baseColor.withOpacity(0.6), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: -10,
                ),
              ],
            ),

            child: Center(
              child: Text(
                "${isProfit ? '+' : ''}${record.profitOrLoss.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: baseColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================== DETAILS DIALOG ======================
  void _showDetailsDialog(
    BuildContext context,
    TradingRecord record,
    dynamic hiveKey,
    double percent,
  ) {
    final theme = Theme.of(context);

    final TextEditingController profitController = TextEditingController(
      text: record.profitOrLoss.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: Text(
          "Edit Record",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
              context,
              "Date",
              DateFormat('d MMMM, yyyy').format(record.date),
            ),

            _detailRow(
              context,
              "Investment",
              "₹ ${record.investment.toStringAsFixed(2)}",
            ),

            const SizedBox(height: 12),

            Text(
              record.profitOrLoss >= 0
                  ? "Reason for Profit: ${record.reason}"
                  : "Reason for Loss: ${record.reason}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: record.profitOrLoss >= 0
                    ? Colors.green
                    : Colors.redAccent,
              ),
            ),

            const SizedBox(height: 10),

            Text("Profit / Loss (Editable)", style: theme.textTheme.bodySmall),

            const SizedBox(height: 6),

            TextField(
              controller: profitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),

              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                prefixText: "₹ ",
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: profitController,
                  builder: (_, value, __) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: profitController.clear,
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            _detailRow(context, "P/L %", "${percent.toStringAsFixed(2)} %"),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              final newProfit = double.tryParse(profitController.text.trim());
              if (newProfit == null) return;

              final updatedRecord = TradingRecord(
                reason: record.reason,
                date: record.date,
                investment: record.investment,
                profitOrLoss: newProfit,
              );

              await Hive.box('tradingData').put(hiveKey, updatedRecord.toMap());

              onDelete(hiveKey);

              if (!context.mounted) return;
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profit/Loss updated")),
              );
            },
            child: const Text("Save", style: TextStyle(color: Colors.green)),
          ),

          TextButton(
            onPressed: () async {
              await Hive.box('tradingData').delete(hiveKey);
              onDelete(hiveKey);

              if (!context.mounted) return;
              Navigator.of(context).pop();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Record deleted")));
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== DETAIL ROW ======================
  Widget _detailRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
