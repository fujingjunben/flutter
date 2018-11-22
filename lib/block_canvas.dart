import 'package:flutter/material.dart';
import 'default_captcha_strategy.dart';
import 'dart:ui' as ui;

class BlockCanvas extends CustomPainter {
  Offset shadowPositon;
  double x;
  Size blockSize;
  ui.Image originImage;
  ui.Image blockImage;
  Paint blockPaint;
  DefaultCaptchaStrategy octagon;
  BlockCanvas({this.shadowPositon, this.x, this.blockImage, this.originImage}) {
    this.blockPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    octagon = DefaultCaptchaStrategy();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawPath(octagon.getBlockShape(origin, size.width, size.height), octagon.getBlockBorderPaint());
    if (blockImage == null) {
      _clipImage(originImage, shadowPositon, size, blockSize).then((onValue) {
        blockImage = onValue;
        canvas.drawImage(blockImage, Offset(x, shadowPositon.dy), Paint());
      });
    }
  }

  @override
  bool shouldRepaint(BlockCanvas painter) {
    return true;
  }

  Future<ui.Image> _clipImage(ui.Image originImage, Offset origin,
      Size canvasSize, Size blockSize) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    canvas.drawImage(originImage, Offset(0, 0), Paint());
    canvas.clipPath(octagon.getBlockShape(origin, blockSize));
    ui.Picture picture = recorder.endRecording();

    final pngBytes = await picture
        .toImage(blockSize.width.toInt(), blockSize.height.toInt())
        .toByteData();

    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}

class CaptchaBackgroundCanvas extends CustomPainter {
  Offset shadowPosition;
  Offset blockPosition;
  Size blockSize;
  Size canvasSize;
  ui.Image backgroundImage;
  ui.Image blockImage;
  Paint shadowAreaPaint;
  DefaultCaptchaStrategy strategy;
  CaptchaBackgroundCanvas(
      {this.shadowPosition,
      this.blockPosition,
      this.blockSize,
      this.canvasSize,
      this.blockImage,
      this.backgroundImage}) {
    strategy = DefaultCaptchaStrategy();
    shadowAreaPaint = strategy.getShadowAreaPaint();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawColor(Colors.green, BlendMode.color);
    // canvas.drawCircle(origin, 30, backgroundPaint);
    print("size: $size");
    // canvas.drawImage(backgroundImage, Offset(0, 0), Paint());
    // canvas.drawColor(Colors.red, BlendMode.color);
    _drawShadowArea(canvas, shadowPosition, blockSize, shadowAreaPaint);
    _drawBlock(canvas, blockImage, blockPosition, Paint());
  }

  @override
  bool shouldRepaint(CaptchaBackgroundCanvas painter) {
    return true;
  }

  void _drawShadowArea(Canvas canvas, Offset position, Size size, Paint paint) {
    var rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    var shape = strategy.getBlockShape(position, size);
    canvas.drawPath(shape, paint);
  }

  void _drawBlock(Canvas canvas, ui.Image image, Offset position, Paint paint) {
    canvas.drawImage(image, position, paint);
  }

  Future<ui.Image> _clipImage(ui.Image originImage, Offset origin,
      Size canvasSize, Size blockSize) async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder);
    var rect = new Rect.fromLTWH(0.0, 0.0, 100.0, 100.0);
    c.clipRect(rect);

    final paint = new Paint();
    paint.strokeWidth = 2.0;
    paint.color = const Color(0xFF333333);
    paint.style = PaintingStyle.fill;

    final offset = new Offset(50.0, 50.0);
    c.drawCircle(offset, 40.0, paint);
    var picture = recorder.endRecording();

    final pngBytes = await picture
        .toImage(100, 100)
        .toByteData(format: ui.ImageByteFormat.png);

    //Aim #1. Upade _image with generated image.
    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
