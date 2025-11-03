// lib/presentation/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
      
  late final AnimationController _controller;
  // Kita buat DUA animasi
  late final Animation<double> _logoAnimation;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controller utama, durasi total 2.5 detik
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // 1. Animasi Logo:
    // Main dari detik 0.0 s/d 1.5 (60% dari total durasi)
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    // 2. Animasi Teks:
    // Main dari detik 1.0 s/d 2.5 (mulai 40% s/d 100%)
    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    // Mulai animasi
    _controller.forward();

    // Pindah halaman setelah 3 detik
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 3), () { // Total splash screen 3 detik
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. Animasi Logo ---
            ScaleTransition(
              scale: _logoAnimation,
              child: FadeTransition(
                opacity: _logoAnimation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxLogoSize = 300.0;
                    final double logoWidth = (50.w < maxLogoSize) ? 50.w : maxLogoSize;

                    return Image.asset(
                      'assets/images/logo.png',
                      width: logoWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.stream, size: logoWidth);
                      },
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // --- 2. Animasi Teks ---
            FadeTransition(
              opacity: _textAnimation, 
              child: Column(
                children: [
                  Text(
                    "Rahmat",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}