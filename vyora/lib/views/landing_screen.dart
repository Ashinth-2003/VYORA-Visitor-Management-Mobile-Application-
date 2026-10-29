import 'package:flutter/material.dart';

import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: .78, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 2400), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100B07),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Image.asset(
                'assets/images/landing_icon.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
