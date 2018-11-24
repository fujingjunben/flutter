import 'package:flutter/material.dart';
import 'block_canvas.dart';
import 'util/image_utils.dart';
import 'dart:ui' as ui;
import 'default_captcha_strategy.dart';
import 'model/captcha_image_store.dart';

class Test2 extends StatefulWidget {
  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  GlobalKey _blockKey = GlobalKey();
  double dx = 0;
  double dy = 100;
  double size = 20;
  double blockCenterX = 250;
  Size blockSize = Size(50, 10);
  double width = 300;
  double height = 200;
  final String imageFile = "images/snow.jpg";
  Widget blockWidget;
  FractionalOffset offset;
  double offsetWidth = 300;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _changeBlockImage();
  }

  @override
  Widget build(BuildContext context) {
    print("screen width: $width");
    return Scaffold(
        appBar: AppBar(
          title: Text("ClipPath test"),
        ),
        //   body: Column(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: <Widget>[
        //         Container(
        //           width: width,
        //           height: height,
        //           decoration: BoxDecoration(
        //               image: DecorationImage(
        //                   image: AssetImage(imageFile), fit: BoxFit.fill)),
        //         ),
        //         Container(
        //           child: Transform.translate(
        //             offset: Offset(-blockCenterX + size, 0),
        //             child: blockWidget,
        //           ),
        //         ),
        //       ]),
        // );
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("当前位置：$dx"),
              Stack(
                children: <Widget>[
                  Container(alignment: Alignment.center, child: _getCaptcha()),
                  Container(
                      alignment: offset,
                      child: Container(
                          color: Colors.yellow.withOpacity(0.2),
                          child: blockWidget))
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
          onPressed: () {
            _getPosition();
            _getSize();
          },
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
        shadowPosition: Offset(blockCenterX, dy),
        blockSize: Size(size, size),
        canvasSize: Size(width, height),
        blockPosition: Offset(dx, dy),
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

  Widget _getOval() {
    return ClipOval(
      clipper: OvalClipper(
        origin: Offset(blockCenterX, dy),
        blockSize: Size(size, size),
      ),
      child: Image.asset(imageFile),
    );
  }

  Widget _getBlock() {
    _resetBlockOffset();
    return Transform.translate(
        key: _blockKey,
        offset: Offset(-blockCenterX + size, 0),
        child: Stack(children: [
          ClipPath(
            clipper: BlockClipper(
              origin: Offset(blockCenterX, dy),
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
          ),
          CustomPaint(
            painter: BorderPaint(
              origin: Offset(blockCenterX, dy),
              radius: size,
            ),
            child: SizedBox(
              width: width,
              height: height,
            ),
          )
        ]));
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
          Offset(dx, dy), Size(offsetWidth, height));
    });
  }

  _resetBlockOffset() {
    setState(() {
      offset = FractionalOffset.fromOffsetAndSize(
          Offset(0, dy), Size(offsetWidth, height));
    });
  }

  _getPosition() {
    RenderBox renderBox = _blockKey.currentContext.findRenderObject();
    var position = renderBox.localToGlobal(Offset.zero);
    print("block position: $position");
  }

  _getSize() {
    RenderBox renderBox = _blockKey.currentContext.findRenderObject();
    Size size = renderBox.size;
    print("block size: $size");
  }
}

class BlockClipper extends CustomClipper<Path> {
  Offset origin;
  Size blockSize;
  BlockClipper({this.origin, this.blockSize});
  @override
  Path getClip(Size size) {
    print("block origin: $origin");
    Path path = Path();
    Rect rect = Rect.fromCircle(center: origin, radius: blockSize.width);
    path.addOval(rect);
    return path;
  }

  @override
  bool shouldReclip(BlockClipper old) {
    return true;
  }
}

class OvalClipper extends CustomClipper<Rect> {
  Offset origin;
  Size blockSize;
  OvalClipper({this.origin, this.blockSize});
  @override
  Rect getClip(Size size) {
    // print("clipper origin: $origin");
    Rect rect = Rect.fromCircle(center: origin, radius: blockSize.width);
    return rect;
  }

  @override
  bool shouldReclip(OvalClipper old) {
    return true;
  }
}

class BorderPaint extends CustomPainter {
  Offset origin;
  double radius;
  BorderPaint({this.origin, this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(origin, radius, paint);
  }

  @override
  bool shouldRepaint(BorderPaint old) {
    return true;
  }
}
