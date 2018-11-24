import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image _image;
  ui.Image canvasImage;

  @override
  void initState() {
    super.initState();
    _image = new Image.network(
      'https://img1.doubanio.com/view/subject/l/public/s29917079.jpg',
    );
  }

  Future<String> get _localPath async {
    final directory =
        await getApplicationDocumentsDirectory(); //From path_provider package
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/tempImage.png');
  }

  Future<File> writeImage(ByteData pngBytes) async {
    final file = await _localFile;
    // Write the file
    file.writeAsBytes(pngBytes.buffer.asUint8List());
    return file;
  }

  _generateImage() {
    _generate().then((val) => setState(() {
          canvasImage = val;
        }));
  }

  Future<ui.Image> _generate() async {
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
    var image = Image.memory(pngBytes.buffer.asUint8List());
    var codec = await ui.instantiateImageCodec(pngBytes.buffer.asUint8List());
    var frame = await codec.getNextFrame();
    return frame.image;

    //new Image.memory(pngBytes.buffer.asUint8List());
    // _image = new Image.network(
    //   'https://github.com/flutter/website/blob/master/_includes/code/layout/lakes/images/lake.jpg?raw=true',
    // );

    //Aim #2. Write image to file system.
    //writeImage(pngBytes);
    //Make a temporary file (see elsewhere on SO) and writeAsBytes(pngBytes.buffer.asUInt8List())
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.yellow.withOpacity(0.2),
              child: CustomPaint(
                painter: MyCustomPainter(image: canvasImage),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _generateImage,
        tooltip: 'Generate',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  ui.Image image;
  Paint customPaint;
  MyCustomPainter({this.image}) {
    customPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
  }
  @override
  void paint(Canvas canvas, Size size) {
    print(image.toString());
    print("size: " + size.width.toString() + 'x' + size.height.toString());
    if (image != null) {
      canvas.drawImage(image, Offset(20, 20), customPaint);
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter old) {
    return true;
  }
}
