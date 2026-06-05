import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/providers/device_config_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7)),
    );

    _controller.forward();

    // Navigate after ~2s
    Future.delayed(const Duration(milliseconds: 2000), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final config = ref.read(deviceConfigNotifierProvider);
    final localAuth = ref.read(localAuthNotifierProvider);

    if (config == null) {
      context.go('/setup');
    } else if (localAuth.waiterId == null) {
      context.go('/login');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/images/logo.png',
            width: 260,
            height: 260,
          ),
        ),
      ),
    );
  }
}
