import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StaggerFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayPerItem;

  const StaggerFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.delayPerItem = const Duration(milliseconds: 60),
  });

  @override
  State<StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.durationBase,
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: AppTheme.easeOutStrong),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: AppTheme.easeOutStrong),
      ),
    );
    final delay = widget.delayPerItem * widget.index;
    if (delay > Duration.zero) {
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value.dy * 16),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
