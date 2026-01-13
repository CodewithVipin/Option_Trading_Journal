// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:heat_map/widgets/theme_toggle_icon.dart';

class DeepMarketInsight extends StatefulWidget {
  const DeepMarketInsight({super.key});

  @override
  _DeepMarketInsightState createState() => _DeepMarketInsightState();
}

class _DeepMarketInsightState extends State<DeepMarketInsight> {
  final TextEditingController callOiController = TextEditingController();
  final TextEditingController putOiController = TextEditingController();

  double? pcr;
  String marketMood = "Neutral / Wait for Confirmation";
  Color moodColor = Colors.grey;

  // ---------------- CLEAR ICON ----------------
  Widget _clearIcon(TextEditingController controller) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.clear,
        );
      },
    );
  }

  // ---------------- PCR LOGIC ----------------
  void calculatePCR() {
    final callOi = double.tryParse(callOiController.text);
    final putOi = double.tryParse(putOiController.text);

    if (callOi == null || putOi == null || callOi <= 0 || putOi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter valid numbers. Values should be greater than zero.",
          ),
        ),
      );
      return;
    }

    setState(() {
      pcr = putOi / callOi;
      marketMood = _determineMarketMood(callOi, putOi);
    });
  }

  String _determineMarketMood(double callOi, double putOi) {
    final diff = (putOi - callOi).abs();
    final threshold = 0.5 * (callOi < putOi ? callOi : putOi);

    if (pcr! <= 0.5 || pcr! >= 2.0) {
      if (diff > threshold) {
        if (putOi > callOi) {
          moodColor = Colors.green;
          return "Bullish (Buy Call)";
        } else {
          moodColor = Colors.red;
          return "Bearish (Buy Put)";
        }
      }
    }

    moodColor = Colors.grey;
    return "Neutral / Wait for Confirmation";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ✅ SIMPLE, THEME-AWARE APP BAR
      appBar: AppBar(
        title: const Text("Deep Market Insight"),
        actions: const [ThemeToggleIcon()],
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _modernInputField(
              context: context,
              controller: callOiController,
              hint: "Enter Call OI Change",
            ),

            const SizedBox(height: 15),

            _modernInputField(
              context: context,
              controller: putOiController,
              hint: "Enter Put OI Change",
            ),

            const SizedBox(height: 30),

            _gradientButton(context),

            const SizedBox(height: 35),

            _resultCard(context),

            const SizedBox(height: 20),

            if (moodColor != Colors.grey)
              Center(
                child: Text(
                  "Vipin! Grab Only 10 Points! 😎",
                  style: theme.textTheme.titleMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT FIELD ----------------
  Widget _modernInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: theme.textTheme.bodyMedium,

      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.surface,
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        suffixIcon: _clearIcon(controller),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  // ---------------- BUTTON ----------------
  Widget _gradientButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: calculatePCR,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colors.primary, colors.secondary]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Analyze Market",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- RESULT CARD ----------------
  Widget _resultCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: moodColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Market Mood",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            marketMood,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          if (pcr != null) ...[
            const SizedBox(height: 8),
            Text(
              "PCR: ${pcr!.toStringAsFixed(2)}",
              style: theme.textTheme.titleMedium,
            ),
          ],
        ],
      ),
    );
  }
}
