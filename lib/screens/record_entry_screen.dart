// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:heat_map/model/trading_record.dart';
import 'package:heat_map/screens/heat_map_screen.dart';
import 'package:heat_map/services/theme_service.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class RecordEntryScreen extends StatefulWidget {
  const RecordEntryScreen({super.key});

  @override
  _RecordEntryScreenState createState() => _RecordEntryScreenState();
}

class _RecordEntryScreenState extends State<RecordEntryScreen> {
  final _profitLossController = TextEditingController();
  final _investmentController = TextEditingController();
  final _targetController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _selectedDate;
  bool _hasTarget = false;

  final Box _box = Hive.box('tradingData');

  @override
  void initState() {
    super.initState();
    _loadTargetAmount();

    _box.watch().listen((event) {
      if (event.key == 'targetAmount' && mounted) {
        _loadTargetAmount();
      }
    });
  }

  // ---------- CLEAR ICON ----------
  Widget _clearIcon(TextEditingController controller) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return IconButton(
          icon: const Icon(Icons.clear),
          onPressed: controller.clear,
        );
      },
    );
  }

  // ---------- LOAD TARGET ----------
  void _loadTargetAmount() {
    final raw = _box.get('targetAmount');

    if (raw != null) {
      _hasTarget = true;
      _targetController.text = raw.toStringAsFixed(0);
    } else {
      _hasTarget = false;
      _targetController.clear();
    }
    if (mounted) setState(() {});
  }

  // ---------- SAVE TARGET ----------
  void _saveTargetAmount() {
    final value = double.tryParse(_targetController.text);
    if (value == null || value <= 0) {
      _snack("Enter valid target");
      return;
    }
    _box.put('targetAmount', value);
    _hasTarget = true;
    _snack("Target set to ₹${value.toStringAsFixed(0)}");
    setState(() {});
  }

  void _removeTarget() {
    _box.delete('targetAmount');
    _hasTarget = false;
    _targetController.clear();
    _snack("Target removed");
    setState(() {});
  }

  // ---------- SAVE RECORD ----------
  void _saveRecord() {
    if (_profitLossController.text.isEmpty ||
        _investmentController.text.isEmpty) {
      _snack("Fill required fields");
      return;
    }

    final record = TradingRecord(
      reason: _reasonController.text.trim(),
      profitOrLoss: double.parse(_profitLossController.text),
      investment: double.parse(_investmentController.text),
      date: _selectedDate ?? DateTime.now(),
    );

    _box.add(record.toMap());
    _profitLossController.clear();
    _investmentController.clear();
    _snack("Record saved");
  }

  // ---------- DATE PICKER ----------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ---------- INPUT DECORATION ----------
  InputDecoration _inputDecoration(
    String label,
    TextEditingController controller,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
      filled: true,
      fillColor: theme.colorScheme.surface,
      suffixIcon: _clearIcon(controller),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.3),
      ),
    );
  }

  // ---------- BUTTON ----------
  Widget _actionButton(String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      width: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ---------- SNACK ----------
  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Record Profit / Loss"),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.notifier,
            builder: (_, mode, __) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: ThemeService.instance.toggleLightDark,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARGET CARD
            Card(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _hasTarget
                            ? "Target: ₹${_targetController.text}"
                            : "No target set",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (_hasTarget)
                      TextButton(
                        onPressed: _removeTarget,
                        child: const Text("Remove"),
                      ),
                  ],
                ),
              ),
            ),

            if (!_hasTarget) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        "Set Target Amount (₹)",
                        _targetController,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveTargetAmount,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? "No date selected"
                        : DateFormat('d MMM yyyy').format(_selectedDate!),
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _profitLossController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                "Profit / Loss Amount",
                _profitLossController,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _reasonController,
              decoration: _inputDecoration(
                "Reason for Trade",
                _reasonController,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _investmentController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                "Investment Amount",
                _investmentController,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton("Save Record", _saveRecord),
                _actionButton("View Heatmap", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HeatmapScreen()),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
