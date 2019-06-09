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
  List<String> _paths = List();

  Future<void> loadLatestImages() async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: 1));
    FlutterGalleryPlugin.getPhotoPathsForPeriod(start, end).listen((path) {
      setState(() {
        _paths = List.from(_paths)..add(path);
      });
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
            OutlineButton(
              onPressed: loadLatestImages,
              child: Text(
                'Load latest images',
                style: TextStyle(color: Colors.blueAccent),
              ),
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            Expanded(child: _buildGrid()),
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
      children: _buildGridTileList(_paths.length),
    );
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
      count,
      (int index) => Container(
            child: Image.file(
              File(_paths[index]),
              width: 96.0,
              height: 96.0,
              fit: BoxFit.contain,
            ),
          ),
    );
  }
}
