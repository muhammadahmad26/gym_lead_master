import 'package:flutter/material.dart';

// class BottomNavigationbarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     double w = size.width;
//     double h = size.height;
//     Path path = Path();

//     path.moveTo(w * 0.5, 0);

//     path.quadraticBezierTo(w * 0.2, h * 0.1, 0, h * 0.33);

//     path.lineTo(0, h);
//     path.lineTo(w, h);

//     path.lineTo(w, h * 0.33);

//     path.quadraticBezierTo(w * 0.8, h * 0.1, w * 0.5, 0);

//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }



/// A custom clipper that creates a notch in the center of the navigation bar.
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