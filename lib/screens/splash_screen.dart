// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pushup/auth_gate.dart'; // pastikan path ini sesuai projectmu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _rotateController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation untuk logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Rotate animation untuk background
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Fade animation untuk text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Pulse animation untuk outer circle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });

    // Navigate to AuthGate after 3 seconds (same behavior as kode lama)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated rotating background circles
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Circle 1
                  Positioned(
                    top: -120,
                    left: -120,
                    child: Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Circle 2
                  Positioned(
                    bottom: -160,
                    right: -160,
                    child: Transform.rotate(
                      angle: -_rotateController.value * 2 * math.pi,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.03),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing outer circle behind logo (use Stack to layer)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse animated circle
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final size = 200.0 + (_pulseController.value * 40.0);
                        final borderOpacity = (0.1 - (_pulseController.value * 0.1)).clamp(0.0, 0.1);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(borderOpacity),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    // Scaled logo in center
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey[300]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.12),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 80,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // App title and tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Colors.grey],
                        ).createShader(bounds),
                        child: const Text(
                          'PUSHX',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MOBILE PUSH UP COUNTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final animValue = (_pulseController.value + delay) % 1.0;
                          final opacity = (0.3 + (animValue * 0.7)).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(opacity),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
