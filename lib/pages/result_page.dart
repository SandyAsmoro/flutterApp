import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

class ResultPage extends StatefulWidget {
  final File image;
  ResultPage({required this.image});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _loading = true;
  List? _outputs;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      classifyImage(widget.image);
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classification Result')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.file(widget.image),
                SizedBox(height: 20),
                _outputs != null
                    ? Text(
                        "${_outputs![0]["label"]}\n${(_outputs![0]["confidence"] * 100).toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 20),
                      )
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Classify Again'),
                ),
              ],
            ),
    );
  }
}
