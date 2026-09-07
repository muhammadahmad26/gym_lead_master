import 'package:flutter/material.dart';

class NotchedBottomNavigationBarClipper extends CustomClipper<Path> {
  /// The radius of the circular notch.
  final double notchRadius;

  const NotchedBottomNavigationBarClipper({this.notchRadius = 30.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double notchCenter = size.width / 2;

    // Start from the top-left corner
    path.moveTo(0, 0);

    // Draw a line to the start of the notch
    path.lineTo(notchCenter - notchRadius, 0);

    // Draw the semi-circular notch
    path.arcToPoint(
      Offset(notchCenter + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Continue to the top-right corner and complete the rectangle
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(NotchedBottomNavigationBarClipper oldClipper) {
    // Re-clip if the notch radius changes
    return oldClipper.notchRadius != notchRadius;
  }
}
