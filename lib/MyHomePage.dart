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
          shadowPosition: Offset(150, dy),
          blockSize: Size(size, size),
          canvasSize: Size(width, height),
          blockPosition: Offset(dx, dy),
          backgroundImage: image,
          blockImage: blockImage,
        ),
        child: Container(
          width: width,
          height: height,
          color: Colors.green,
          // decoration: BoxDecoration(
          // image: DecorationImage(
          // image: AssetImage(imageFile), fit: BoxFit.fill)),
        ),
      );
    }
  }

  void _loadImage(String key) async {
    ui.Image originImage = await ImageUtil.loadImage(key);
    // ui.Image clipImage = await _clipImage(
    // originImage, shadowPosition, Size(width, height), blockSize);
    ui.Image clipImage = await createBlock(originImage);
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
    createBlock(image).then((value) {
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

  Future<ui.Image> createBlock(ui.Image image) async {
    print("dx: $dx; dy: $dy");
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder);
    // c.drawImage(image, Offset(0, 0), Paint());
    // var rect = new Rect.fromLTWH(50, 50, 100, 100);
    // var rect = new Rect.fromCircle(center: Offset(dx, dy), radius: size + 10);
    // c.clipRect(rect);
    // c.drawColor(Colors.white, BlendMode.color);

    final paint = new Paint();
    paint.strokeWidth = 0;
    paint.color = const Color(0xFF333333);
    paint.style = PaintingStyle.fill;

    final offset = new Offset(50, 50);
    // c.drawCircle(offset, 10, paint);
    Path path = Path();
    // path.addOval(new Rect.fromCircle(center: Offset(50, 50), radius: 10));
    // c.clipPath(path);
    c.drawColor(Colors.yellow, BlendMode.color);
    c.drawCircle(offset, 10, paint);

    var picture = recorder.endRecording();

    var w = width;
    var h = height;
    final pngBytes = await picture
        .toImage(w.toInt(), h.toInt())
        .toByteData(format: ui.ImageByteFormat.png);

    //Aim #1. Upade _image with generated image.
    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
