import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color verde = Color(0xFF627348);
  static const Color bege = Color(0xFFF3EBD6);

  late final AnimationController _ctrl;

  // Phase 1 — logo aparece (0 → 45%)
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFadeIn;

  // Phase 2 — pulse suave (45% → 62%)
  late final Animation<double> _logoPulse;

  // Phase 3 — sobe e some (62% → 100%)
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoFadeOut;

  // Background: bege → branco no final
  late final Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.48, curve: Curves.elasticOut),
      ),
    );

    _logoPulse =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.48, 0.62, curve: Curves.easeInOut),
          ),
        );

    _logoSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.45))
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.62, 1.0, curve: Curves.easeInCubic),
          ),
        );

    _logoFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );

    _bgColor = ColorTween(begin: bege, end: Colors.white).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.58, 1.0, curve: Curves.easeInOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // combina escala base + pulse
        final scale = _logoScale.value * _logoPulse.value;
        final opacity = (_logoFadeIn.value * _logoFadeOut.value).clamp(
          0.0,
          1.0,
        );

        return Scaffold(
          backgroundColor: _bgColor.value ?? bege,
          body: Center(
            child: SlideTransition(
              position: _logoSlide,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: child),
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 160),
          const SizedBox(height: 16),
          const Text(
            'CURADO BEM',
            style: TextStyle(
              color: verde,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'cuidado que faz bem',
            style: TextStyle(
              color: verde,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
