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
  double dy = 50;
  double size = 10;
  Offset shadowPosition = Offset(150, 50);
  Size blockSize = Size(10, 10);
  double width = 300;
  double height = 300;
  final String imageFile = "images/ocean.jpeg";
  ui.Image image;
  ui.Image blockImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadImage(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("测试"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getCaptcha(),
              Slider(
                value: dx,
                min: 0,
                max: width,
                onChanged: (v) {
                  setState(() {
                    dx = v;
                  });
                },
              ),
              Text("当前位置：$dx"),
              _getSizeInput(),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _changeBlockImage,
          tooltip: "生成新滑块",
          child: Icon(Icons.add),
        ));
  }

  Widget _getSizeInput() {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                setState(() {
                  size = size + 2;
                });
                _changeBlockImage();
              }),
          IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: () {
              setState(() {
                size = size - 2;
              });
              _changeBlockImage();
            },
          )
        ],
      ),
    ]);
  }

  Widget _getCaptcha() {
    if (image == null || blockImage == null) {
      return Text("loading...");
    } else {
      return CustomPaint(
        foregroundPainter: CaptchaBackgroundCanvas(
          shadowPosition: shadowPosition,
          blockSize: Size(size, size),
          canvasSize: Size(width, height),
          blockPosition: Offset(dx, dy),
          backgroundImage: image,
          blockImage: blockImage,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageFile), fit: BoxFit.fill)),
        ),
      );
    }
  }

  void _loadImage(String key) async {
    ui.Image originImage = await ImageUtil.loadImage(key);
    // ui.Image clipImage = await _clipImage(
    // originImage, shadowPosition, Size(width, height), blockSize);
    ui.Image clipImage = await createBlock();
    // ui.Image clipImage = await block(
    // originImage, shadowPosition, Size(width, height), blockSize);
    setState(() {
      image = originImage;
      blockImage = clipImage;
    });
    // return CaptchaImageStore(origin: originImage, clip: clipImage);
  }

  void _changeBlockImage() {
    // _clipImage(image, Offset(dx, dy), Size(width, height), Size(size, size))
    createBlock().then((value) {
      setState(() {
        blockImage = value;
      });
    });
  }

  Future<ui.Image> _clipImage(ui.Image originImage, Offset shadowPosition,
      Size canvasSize, Size blockSize) async {
    DefaultCaptchaStrategy strategy = DefaultCaptchaStrategy();
    Path blockShape = strategy.getBlockShape(shadowPosition, blockSize);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    canvas.drawImage(originImage, Offset(0, 0), Paint());

    canvas.clipPath(blockShape);
    ui.Picture picture = recorder.endRecording();

    final pngBytes = await picture
        .toImage(100, 100)
        .toByteData(format: ui.ImageByteFormat.png);

    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> createBlock() async {
    print("dx: $dx; dy: $dy");
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    // var rect = new Rect.fromLTWH(20, dy, 100.0, 100.0);
    var rect = new Rect.fromCircle(center: Offset(dx, dy), radius: size + 10);
    Path path = Path();
    path.addOval(rect);
    c.clipPath(path);
    // c.clipRect(rect);
    c.drawColor(Colors.white, BlendMode.color);

    final paint = new Paint();
    paint.strokeWidth = 2.0;
    paint.color = const Color(0xFF333333);
    paint.style = PaintingStyle.fill;

    final offset = new Offset(dx, dy);
    c.drawCircle(offset, size, paint);
    var picture = recorder.endRecording();

    var w = dx + size;
    var h = dy + size;
    final pngBytes = await picture
        .toImage(w.toInt(), h.toInt())
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

class HomePage extends StatelessWidget {
  final Offset shadowPosition = Offset(100, 100);
  final Size blockSize = Size(100, 100);
  final double width = 300;
  final double height = 300;
  final String imageFile = "images/ocean.jpeg";
  ui.Image image;
  ui.Image blockImage;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("测试"),
        ),
        body: Column(children: <Widget>[
          Slider(
            value: 0,
            min: 0,
            max: 400,
            onChanged: null,
          ),
        ]));
  }

  Future<CaptchaImageStore> _loadImage(String key) async {
    ui.Image originImage = await ImageUtil.loadImage(key);
    ui.Image clipImage = await _clipImage(
        originImage, shadowPosition, Size(width, height), blockSize);

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
}
