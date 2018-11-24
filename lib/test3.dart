import 'package:flutter/material.dart';
import 'block_canvas.dart';
import 'util/image_utils.dart';
import 'dart:ui' as ui;
import 'default_captcha_strategy.dart';
import 'model/captcha_image_store.dart';

class Test3 extends StatefulWidget {
  @override
  _Test3State createState() => _Test3State();
}

class _Test3State extends State<Test3> {
  double dx = 50;
  double dy = 50;
  double size = 10;
  Offset shadowPosition = Offset(150, 50);
  Size blockSize = Size(10, 10);
  double width = 300;
  double height = 200;
  final String imageFile = "images/ocean.jpeg";
  Widget blockWidget;
  FractionalOffset offset;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      blockWidget = _getBlock();
    });
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
              Text("当前位置：$dx"),
              Stack(
                children: <Widget>[
                  _getCaptcha(),
                  Positioned(
                    top: dy - size,
//                    bottom: height - dy - size,
                    left: dx,
                    child: Container(
                      color: Colors.red.withOpacity(0.2),
                      child: CircleAvatar(backgroundColor: Colors.black, radius: size,),
                  ))
                ],
              ),
              Slider(
                value: dx,
                min: 0,
                max: width,
                onChanged: (v) {
                  _changeBlockPosition(v.toDouble());
                },
              ),
              _changeBlockSize(),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _changeBlockImage,
          tooltip: "生成新滑块",
          child: Icon(Icons.add),
        ));
  }

  Widget _changeBlockSize() {
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
    return CustomPaint(
      foregroundPainter: CaptchaBackgroundCanvas(
        shadowPosition: Offset(150, dy),
        blockSize: Size(size, size),
        canvasSize: Size(width, height),
        blockPosition: Offset(dx, dy),
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

  Widget _getBlock() {
    return ClipPath(
      clipper: BlockClipper(
        origin: Offset(size, dy),
        blockSize: Size(size, size),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(imageFile),
          fit: BoxFit.fill,
        )),
      ),
    );
  }

  _changeBlockImage() {
    setState(() {
      blockWidget = _getBlock();
    });
  }

  _changeBlockPosition(double value) {
    setState(() {
      dx = value;
      offset = FractionalOffset.fromOffsetAndSize(
          Offset(value, dy), Size(width, height));
    });
  }
}

class BlockClipper extends CustomClipper<Path> {
  Offset origin;
  Size blockSize;

  BlockClipper({this.origin, this.blockSize});

  @override
  Path getClip(Size size) {
    Path path = Path();
    var left = origin.dx - blockSize.width;
    var top = origin.dy - blockSize.width;
    print("clipper left: $left; top: $top; size: ${blockSize.width}");
//    Rect rect = Rect.fromLTWH(left, top, 2 * blockSize.width, 2 * blockSize.width);
    Rect rect = Rect.fromCircle(center: origin, radius: blockSize.width);
    path.addOval(rect);
    return path;
  }

  @override
  bool shouldReclip(BlockClipper old) {
    return true;
  }
}
