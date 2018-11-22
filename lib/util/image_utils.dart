import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class ImageUtil {
  static Future<ui.Image> loadImage(String key) async {
    final ByteData data = await rootBundle.load(key);
    if (data == null) {
      throw "Unable to read data";
    }
    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
