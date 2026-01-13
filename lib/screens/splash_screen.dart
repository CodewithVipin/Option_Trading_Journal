// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:heat_map/screens/land_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<Offset> slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    slideUp = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: const LandScreen(),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ☕ COFFEE STANDARD THEME-AWARE GRADIENT
  LinearGradient _backgroundGradient(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              colors.surfaceVariant, // mocha layer
              theme.scaffoldBackgroundColor, // espresso base
            ]
          : [
              colors.primary.withOpacity(0.18), // latte tint
              theme.scaffoldBackgroundColor, // milk white
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),

        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(
                position: slideUp,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ☕ HERO TITLE
                    Hero(
                      tag: "trading_header",
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          "Option Trading App",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.45)
                                    : Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Powered by Vipin Maurya",
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          theme.brightness == Brightness.dark ? 0.75 : 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
