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
  final String imageFile = "images/snow.jpg";
  double dx = 0;
  double size = 10;
  double blockCenterX = 250;
  double blockCenterY = 100;
  double width = 300;
  double height = 300;
  ui.Image image;
  ui.Image blockImage;

  @override
  void initState() {
    super.initState();
    _loadImage(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("test"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _getCaptcha(),
              Slider(
                value: dx,
                min: 0,
                max: width - (MediaQuery.of(context).size.width - width) / 2,
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
          shadowPosition: Offset(blockCenterX, blockCenterY),
          blockSize: Size(size, size),
          canvasSize: Size(width, height),
          blockPosition: Offset(dx, blockCenterY),
          backgroundImage: image,
          blockImage: blockImage,
        ),
        child: Container(
          width: width,
          height: height,
          // color: Colors.green,
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
    // originImage,
    // Offset(blockCenterX, blockCenterY),
    // Size(width, height),
    // Size(size, size));
    ui.Image clipImage = await createBlock(originImage);
    // ui.Image clipImage = await block(
    // originImage, shadowPosition, Size(width, height), blockSize);
    setState(() {
      image = originImage;
      blockImage = clipImage;
    });
  }

  void _changeBlockImage() {
    createBlock(image)
        // _clipImage(image, Offset(blockCenterX, blockCenterY), Size(width, height),
        // Size(size, size))
        .then((value) {
      setState(() {
        blockImage = value;
      });
    });
  }

  Future<ui.Image> _clipImage(ui.Image originImage, Offset blockCenter,
      Size canvasSize, Size blockSize) async {
    DefaultCaptchaStrategy strategy = DefaultCaptchaStrategy();
    Path blockShape = strategy.getBlockShape(blockCenter, blockSize);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    // canvas.drawImage(originImage, Offset(0, 0), Paint());
    // canvas.translate(
    // blockSize.width - blockCenter.dx, blockSize.height - blockCenter.dy);

    // canvas.clipPath(blockShape);
    // canvas.drawColor(Colors.yellow, BlendMode.color);
    // canvas.drawImage(originImage, Offset(0, 0), Paint());
    canvas.drawColor(Colors.yellow, BlendMode.color);
    ui.Picture picture = recorder.endRecording();

    double imageWidth = canvasSize.width;
    double imageHeight = canvasSize.height;
    final pngBytes = await picture
        .toImage(imageWidth.ceil(), imageHeight.ceil())
        .toByteData(format: ui.ImageByteFormat.png);

    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> createBlock(ui.Image image) async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    // ImageUtil.paintImage(
    // image, Offset.zero & Size(width, height), c, Paint(), BoxFit.fill);
    // var rect = new Rect.fromLTWH(50, 50, 100, 100);
    // var rect = new Rect.fromCircle(
    // center: Offset(blockCenterX, blockCenterY), radius: size * 3);
    // c.clipRect(rect);
    // c.drawColor(Colors.blue, BlendMode.color);

    final paint = new Paint();
    paint.strokeWidth = 0;
    paint.color = const Color(0xFF333333);
    paint.style = PaintingStyle.fill;

    // 将画布的左上角位置移动到包围截图的矩形的左上角
    // 然后再进行截图，这样可以用toImage方法将截图的部分正好取出来；
    c.translate(-blockCenterX + size, -blockCenterY + size);
    final offset = new Offset(blockCenterX, blockCenterY);
    // c.drawCircle(offset, 10, paint);
    Path path = Path();
    path.addOval(new Rect.fromCircle(
        center: Offset(blockCenterX, blockCenterY), radius: size));
    c.clipPath(path);
    // var rect = new Rect.fromCircle(center: offset, radius: size);
    // c.clipRect(rect);
    // c.drawColor(Colors.yellow, BlendMode.color);
    // c.drawCircle(offset, 10, paint);
    ImageUtil.paintImage(
        image, Offset.zero & Size(width, height), c, Paint(), BoxFit.fill);

    var picture = recorder.endRecording();

    var w = size * 2;
    var h = size * 2;
    final pngBytes = await picture
        .toImage(w.ceil(), h.ceil())
        .toByteData(format: ui.ImageByteFormat.png);

    //Aim #1. Upade _image with generated image.
    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;
  }
}
