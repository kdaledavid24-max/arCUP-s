import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Splash Screen that displays the Food Ordering logo, tagline, and loading animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Navigate to Main Screen after 2.2 seconds
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Background ambient gold glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldAccent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldAccent.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Central Branding Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shop Logo Emblem
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cardSurface,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.goldAccent.withValues(alpha: 0.3),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.goldAccent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.goldAccent,
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 64,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shop Name
                    const Text(
                      'Food Ordering',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Freshly Brewed • Freshly Made',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppTheme.goldAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Modern Loading Spinner
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Version Note
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Food Ordering System • Localhost',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
