import 'package:flutter/material.dart';
import 'dart:math';

class DefaultCaptchaStrategy {
  @override
  Path getBlockShape(Offset origin, Size size) {
    print("${this.toString()}@ size: $size; origin: $origin");
    var startX = origin.dx;
    var startY = origin.dy;
    double dx = size.width / 4;
    double dy = size.height / 4;
    Radius r = Radius.circular(dx / 10);

    Path path = new Path();
    path.addRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(startX, startY, dx, dy), r));
    return path;
  }

  Path getOctagon(Offset origin, Size size) {
    var startX = origin.dx;
    var startY = origin.dy;
    double dx = size.width / 4;
    double dy = size.height / 4;
    double ds = dx * 1.414;

    // clockwise
    Path path = new Path();
    path.moveTo(startX, startY); // 1
    path.relativeLineTo(dx, -dy);
    path.relativeLineTo(ds, 0); //3
    path.relativeLineTo(dx, dy); // 4
    path.relativeLineTo(0, ds); // 5
    path.relativeLineTo(-dx, dy); // 6
    path.relativeLineTo(-ds, 0); // 7
    path.relativeLineTo(-dx, -dy); // 8
    path.close();
    return path;
  }

  Paint getBlockBorderPaint() {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..color = Colors.greenAccent;

    return paint;
  }

  Paint getShadowAreaPaint() {
    Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    return paint;
  }
}
