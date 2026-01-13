// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:heat_map/model/trading_record.dart';
import 'package:heat_map/screens/heat_map_screen.dart';
import 'package:heat_map/theme/app_colors.dart';
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

  Widget _clearIcon(TextEditingController controller) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) {
          return const SizedBox.shrink();
        }
        return IconButton(
          icon: const Icon(Icons.clear, color: Colors.white54),
          onPressed: () => controller.clear(),
        );
      },
    );
  }

  // LOAD TARGET AMOUNT
  void _loadTargetAmount() {
    final dynamic raw = _box.get('targetAmount');

    if (raw != null) {
      _hasTarget = true;
      if (raw is int) {
        _targetController.text = raw.toString();
      } else if (raw is double) {
        _targetController.text = raw.toStringAsFixed(0);
      } else {
        _targetController.text = raw.toString();
      }
    } else {
      _hasTarget = false;
      _targetController.clear();
    }

    if (mounted) setState(() {});
  }

  // SAVE TARGET
  void _saveTargetAmount() {
    final value = double.tryParse(_targetController.text);

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid target amount.")),
      );
      return;
    }

    _box.put('targetAmount', value);

    if (_box.containsKey('targetAlertShownFor')) {
      _box.delete('targetAlertShownFor');
    }

    _hasTarget = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Target updated to ₹${value.toStringAsFixed(0)}")),
    );

    if (mounted) setState(() {});
  }

  // REMOVE TARGET
  void _removeTarget() {
    if (_box.containsKey('targetAmount')) {
      _box.delete('targetAmount');
    }
    _hasTarget = false;
    _targetController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Target Removed")));

    if (mounted) setState(() {});
  }

  bool _validateFields() {
    if (_profitLossController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a profit/loss amount.")),
      );
      return false;
    }

    if (_investmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an investment amount.")),
      );
      return false;
    }

    return true;
  }

  void _saveRecord(BuildContext context) {
    if (!_validateFields()) return;

    final profitLoss = double.tryParse(_profitLossController.text) ?? 0.0;
    final investment = double.tryParse(_investmentController.text) ?? 0.0;
    final date = _selectedDate ?? DateTime.now();
    final reason = _reasonController.text.trim();
    final record = TradingRecord(
      reason: reason,
      profitOrLoss: profitLoss,
      investment: investment,
      date: date,
    );

    _box.add(record.toMap());

    _profitLossController.clear();
    _investmentController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Record Saved!")));
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ----------------------- UI + DECORATORS -----------------------

  InputDecoration _inputDecoration(
    String label,
    TextEditingController controller,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: darkTextColor),
      filled: true,
      fillColor: darkTabColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: buttonColor, width: 1.3),
      ),
      suffixIcon: _clearIcon(controller), // ✅ ADD THIS
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      width: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 6,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: darkButtonTextColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _targetStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkTabColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _hasTarget
                  ? "Target: ₹${_targetController.text}"
                  : "No target set",
              style: const TextStyle(
                color: darkTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_hasTarget)
            TextButton(
              onPressed: _removeTarget,
              child: const Text(
                "Remove",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----------------------- MAIN UI -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        title: const Text("Record Profit/Loss"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _targetStatusCard(),
              const SizedBox(height: 16),

              if (!_hasTarget)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: darkTextColor),
                        decoration: _inputDecoration(
                          "Set Target Amount (₹)",
                          _targetController,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.save, color: buttonColor),
                      onPressed: _saveTargetAmount,
                    ),
                  ],
                ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? "No date selected"
                          : "Date: ${DateFormat('d MMMM, yyyy').format(_selectedDate!)}",
                      style: const TextStyle(color: darkTextColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context),
                    child: const Text(
                      "Pick Date",
                      style: TextStyle(color: buttonColor),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _profitLossController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: darkTextColor),
                decoration: _inputDecoration(
                  "Profit / Loss Amount",
                  _profitLossController,
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: darkTextColor),
                decoration: _inputDecoration(
                  "Reason For trade",
                  _reasonController,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _investmentController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: darkTextColor),
                decoration: _inputDecoration(
                  "Investment Amount",
                  _investmentController,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton("Save Record", () => _saveRecord(context)),
                  _actionButton("View Heatmap", () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (_, animation, secondaryAnimation) =>
                            const HeatmapScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          final offsetAnimation =
                              Tween<Offset>(
                                begin: const Offset(
                                  0.1,
                                  0,
                                ), // subtle slide from right
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              );

                          final fadeAnimation = Tween<double>(begin: 0, end: 1)
                              .animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeIn,
                                ),
                              );

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
