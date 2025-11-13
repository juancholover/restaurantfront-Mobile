import 'package:flutter/material.dart';

class FadeSlideWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeSlideWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<FadeSlideWrapper> createState() => _FadeSlideWrapperState();
}

class _FadeSlideWrapperState extends State<FadeSlideWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
