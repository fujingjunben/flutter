import 'package:flutter/material.dart';

abstract class CaptchaStrategy {
  final double width;
  final double height;

  CaptchaStrategy({this.width, this.height});

  Path blockPath;
  /**
   * 定义滑块图片的形状
   */
  Path getBlockShape();

  Paint getBlockBorderPaint();

  void generateBlockShape();
}
