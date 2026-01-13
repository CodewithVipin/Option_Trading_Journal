// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:heat_map/model/trading_record.dart';
import 'package:heat_map/screens/profit_loss_heatmap.dart';
import 'package:heat_map/screens/summary_details.dart';
import 'package:hive/hive.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  _HeatmapScreenState createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final Box _tradingDataBox = Hive.box('tradingData');

  double _parseToDoubleSafe(dynamic raw, [double fallback = 0.0]) {
    if (raw == null) return fallback;
    if (raw is double) return raw;
    if (raw is int) return raw.toDouble();
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? fallback;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // ---------------- COLLECT RECORDS ----------------
    final entries = _tradingDataBox.toMap().entries.where(
      (e) => e.value is Map,
    );

    final keys = entries.map((e) => e.key).toList();
    final records = entries
        .map((e) => TradingRecord.fromMap(Map<String, dynamic>.from(e.value)))
        .toList();

    // ---------------- SUMMARY ----------------
    final totalProfit = records.fold(
      0.0,
      (sum, r) => sum + _parseToDoubleSafe(r.profitOrLoss),
    );

    final totalInvestment = records.fold(
      0.0,
      (sum, r) => sum + _parseToDoubleSafe(r.investment),
    );

    final avgProfit = records.isEmpty ? 0.0 : totalProfit / records.length;

    final avgProfitPercent = totalInvestment == 0
        ? 0.0
        : (totalProfit / totalInvestment) * 100;

    // ---------------- TARGET ----------------
    final rawTarget = _tradingDataBox.get('targetAmount');
    final targetAmount = _parseToDoubleSafe(rawTarget, 0.0);

    final coverTarget = targetAmount == 0
        ? 0.0
        : (totalProfit / targetAmount) * 100;

    // ---------------- TARGET ACHIEVED ----------------
    if (targetAmount > 0 && totalProfit >= targetAmount) {
      final shownFor = _tradingDataBox.get('targetAlertShownFor');
      if (shownFor == null ||
          _parseToDoubleSafe(shownFor, -1) != targetAmount) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;

          await showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Target Achieved 🎯"),
              content: const Text(
                "You successfully achieved your target. Set a new one!",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );

          try {
            if (_tradingDataBox.containsKey('targetAmount')) {
              await _tradingDataBox.delete('targetAmount');
            }
            await _tradingDataBox.put('targetAlertShownFor', targetAmount);
          } catch (_) {}

          if (mounted) setState(() {});
        });
      }
    }

    // ================= UI =================
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(title: const Text("Profit / Loss Heatmap")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: records.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryDetails(
                    coverTarget: coverTarget,
                    targetAmount: targetAmount == 0 ? 100000.0 : targetAmount,
                    totalProfit: totalProfit,
                    totalInvestment: totalInvestment,
                    avgProfit: avgProfit,
                    avgProfitPercent: avgProfitPercent,
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: ProfitLossHeatmap(
                      records: records,
                      keys: keys,
                      onDelete: (_) => setState(() {}),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  "No Analytics!",
                  style: theme.textTheme.titleMedium,
                ),
              ),
      ),

      // ================= DELETE FAB =================
      floatingActionButton: Visibility(
        visible: records.isNotEmpty,

        child: GestureDetector(
          onTap: () async {
            final deleteConfirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                title: Text(
                  "Delete All Records",
                  style: theme.textTheme.titleMedium,
                ),

                content: Text(
                  "Are you sure you want to delete all records? This action cannot be undone.",
                  style: theme.textTheme.bodyMedium,
                ),

                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );

            if (deleteConfirmed == true) {
              final keysToDelete = _tradingDataBox
                  .toMap()
                  .entries
                  .where((e) => e.value is Map)
                  .map((e) => e.key)
                  .toList();

              for (final key in keysToDelete) {
                await _tradingDataBox.delete(key);
              }

              if (_tradingDataBox.containsKey('targetAlertShownFor')) {
                await _tradingDataBox.delete('targetAlertShownFor');
              }

              if (mounted) setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All records deleted")),
              );
            }
          },

          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent.shade400, Colors.red.shade700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
