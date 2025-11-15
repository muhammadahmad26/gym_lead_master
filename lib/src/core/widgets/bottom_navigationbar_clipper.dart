import 'package:flutter/material.dart';

class BottomNavigationbarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();

    path.moveTo(w * 0.5, 0);

    path.quadraticBezierTo(
      w * 0.2,
      h * 0.1,
      0,
      h * 0.33,
    );

    path.lineTo(0, h);
    path.lineTo(w, h);

    path.lineTo(w, h * 0.33);

    path.quadraticBezierTo(
      w * 0.8,
      h * 0.1,
      w * 0.5,
      0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
