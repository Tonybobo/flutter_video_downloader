import 'package:flutter/material.dart';

class AnimatedFlutterBrowserLogo extends StatefulWidget {
  const AnimatedFlutterBrowserLogo({
    super.key,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.size = 100.0,
  });

  final Duration animationDuration;
  final double size;

  @override
  State<AnimatedFlutterBrowserLogo> createState() =>
      _AnimatedFlutterBrowserLogoState();
}

class _AnimatedFlutterBrowserLogoState extends State<AnimatedFlutterBrowserLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.75, end: 2.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticInOut)),
      child: SizedBox(
        height: widget.size,
        width: widget.size,
        child: const CircleAvatar(
          backgroundImage: AssetImage("assets/images/icon.png"),
        ),
      ),
    );
  }
}
