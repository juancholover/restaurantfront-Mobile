import 'package:flutter/material.dart';

PageRouteBuilder fadeTransition(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 900),
    pageBuilder: (_, animation, __) {
      return FadeTransition(opacity: animation, child: page);
    },
  );
}

PageRouteBuilder fadeSlideTransition(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 900),
    pageBuilder: (_, animation, __) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offsetAnimation, child: page),
      );
    },
  );
}
