import 'package:flutter/material.dart';

class Pulsing extends StatefulWidget {
  const Pulsing({
    super.key,
    required this.child,
    this.minScale = 0.94,
    this.maxScale = 1.06,
    this.period = const Duration(milliseconds: 800),
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration period;

  @override
  State<Pulsing> createState() => _PulsingState();
}

class _PulsingState extends State<Pulsing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat(reverse: true);
    _scale = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
