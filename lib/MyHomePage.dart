import 'package:flutter/material.dart';
import 'block_canvas.dart';
import 'util/image_utils.dart';
import 'dart:ui' as ui;
import 'default_captcha_strategy.dart';
import 'model/captcha_image_store.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double dx = 50;
  double dy = 100;
  Offset shadowPosition = Offset(100, 100);
  Size blockSize = Size(100, 100);
  double width = 300;
  double height = 300;
  final String imageFile = "images/ocean.jpeg";
  ui.Image image;
  ui.Image blockImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder<CaptchaImageStore>(
        future: _loadImage(imageFile),
        builder:
            (BuildContext context, AsyncSnapshot<CaptchaImageStore> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text("加载中");
              break;
            default:
              if (snapshot.hasError) {
                return Text("加载失败");
              } else {
                return CustomPaint(
                  foregroundPainter: CaptchaBackgroundCanvas(
                    shadowPosition: shadowPosition,
                    blockSize: blockSize,
                    canvasSize: Size(width, height),
                    blockPosition: Offset(dx, dy),
                    backgroundImage: snapshot.data.origin,
                    blockImage: snapshot.data.clip,
                  ),
                  child: Container(
                    color: Colors.green,
                    child: SizedBox(
                        width: width,
                        height: height,
                        child: Image.asset(imageFile)),
                  ),
                );
              }
          }
        });

    return Scaffold(
        appBar: AppBar(
          title: Text("测试"),
        ),
        body: Column(children: <Widget>[
          futureBuilder,
          Slider(
            value: dx,
            min: 0,
            max: 400,
            onChanged: (v) {
              setState(() {
                dx = v;
              });
            },
          ),
          Text("当前位置：$dx"),
        ]));
  }

  Future<CaptchaImageStore> _loadImage(String key) async {
    ui.Image originImage = await ImageUtil.loadImage(key);
    ui.Image clipImage = await _clipImage(
        originImage, shadowPosition, Size(width, height), blockSize);
    // ui.Image clipImage = await createBlock();
    // ui.Image clipImage = await block(
    // originImage, shadowPosition, Size(width, height), blockSize);

    return CaptchaImageStore(origin: originImage, clip: clipImage);
  }

  Future<ui.Image> _clipImage(ui.Image originImage, Offset shadowPosition,
      Size canvasSize, Size blockSize) async {
    DefaultCaptchaStrategy strategy = DefaultCaptchaStrategy();
    Path blockShape = strategy.getBlockShape(shadowPosition, blockSize);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    canvas.drawImage(originImage, Offset(0, 0), Paint());

    Path blockBorderShape = strategy.getBlockShape(
        Offset(shadowPosition.dx + 10, shadowPosition.dy + 10),
        Size(blockSize.width + 10, blockSize.height + 10));

    canvas.drawPath(blockShape, strategy.getBlockBorderPaint());

    canvas.clipPath(blockBorderShape);
    ui.Picture picture = recorder.endRecording();

    final pngBytes = await picture
        .toImage(
            (blockSize.width + 30).toInt(), (blockSize.height + 30).toInt())
        .toByteData(format: ui.ImageByteFormat.png);

    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> createBlock() async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
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
        .toImage(50, 50)
        .toByteData(format: ui.ImageByteFormat.png);

    //Aim #1. Upade _image with generated image.
    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> block(ui.Image originImage, Offset origin, Size canvasSize,
      Size blockSize) async {
    print("canvasSize: $canvasSize");
    print("origin: $origin");
    print("blockSize: $blockSize");
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    // canvas.drawImage(originImage, Offset(0, 0), Paint());
    // canvas.clipPath(
    // octagon.getBlockShape(origin, blockSize.width, blockSize.height));
    canvas.clipRect(Rect.fromLTWH(70, 70, 100, 100));
    Paint blockStrokePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(50, 50), 50, blockStrokePaint);
    ui.Picture picture = recorder.endRecording();

    final pngBytes = await picture
        .toImage(70, 70)
        .toByteData(format: ui.ImageByteFormat.png);

    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
