import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gallery_plugin/flutter_gallery_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Object> _images = List();

  Future<void> loadAllImages() async {
    final images = await FlutterGalleryPlugin.getAllImages();
    setState(() {
      _images = images;
    });
  }

  Future<void> loadTodaysImages() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final images = await FlutterGalleryPlugin.getImagesForPeriod(start, now);
    setState(() {
      _images = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Gallery'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                OutlineButton(
                  onPressed: loadAllImages,
                  child: Text(
                    'Load all images',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                OutlineButton(
                  onPressed: loadTodaysImages,
                  child: Text(
                    'Load todays images',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ],
            ),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.extent(
      shrinkWrap: true,
      maxCrossAxisExtent: 150.0,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: _buildGridTileList(_images.length),
    );
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
      count,
      (int index) => Container(
            child: Image.file(
              File(_images[index].toString()),
              width: 96.0,
              height: 96.0,
              fit: BoxFit.contain,
            ),
          ),
    );
  }
}
