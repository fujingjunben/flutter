import 'package:flutter/material.dart';
import 'dart:math';
import 'captcha_strategy.dart';
import 'dart:ui' as ui;
import 'MyHomePage.dart';
import 'test2.dart';
import 'test3.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String imageFile = "images/ocean.jpeg";
  final double width = 300.0;
  final double height = 200.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: MyHomePage(),
    );
  }

  ui.Image getBlock() {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas blockCanvas = Canvas(recorder);
    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    blockCanvas.drawCircle(Offset(50, 50), 10, paint);
    Rect clipRect = Rect.fromCircle(center: Offset(50, 50), radius: 10);
    blockCanvas.clipRect(clipRect);
    ui.Picture picture = recorder.endRecording();
    ui.Image block = picture.toImage(20, 20);
    return block;
  }
}

class Octagon extends CaptchaStrategy {
  Octagon({double width, double height}) : super(width: width, height: height) {
    generateBlockShape();
  }
  @override
  void generateBlockShape() {
    Path path = new Path();

    var _random = Random();
    double length = min(width, height);

    print("clipImage length: " + length.toString());

    double dy = length / 16;
    double dx = length / 16;
    double ds = dx * 1.414;
    double startX = 0.0 + _random.nextInt((length - 2 * dx - ds).toInt());
    double startY = dy + Random().nextInt((length - ds - dy).toInt());
    // clockwise
    path.moveTo(startX, startY); // 1
    path.relativeLineTo(dx, -dy);
    path.relativeLineTo(ds, 0); //3
    path.relativeLineTo(dx, dy); // 4
    path.relativeLineTo(0, ds); // 5
    path.relativeLineTo(-dx, dy); // 6
    path.relativeLineTo(-ds, 0); // 7
    path.relativeLineTo(-dx, -dy); // 8
    path.close();
    this.blockPath = path;
  }

  Paint getBlockBorderPaint() {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..color = Colors.greenAccent;

    return paint;
  }

  Path getBlockShape() {
    return blockPath;
  }
}
