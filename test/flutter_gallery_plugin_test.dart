import 'package:flutter/services.dart';
import 'package:flutter_gallery_plugin/flutter_gallery_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_gallery_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getAllImages exists', () async {
    expect(FlutterGalleryPlugin.getAllImages, isA<Function>());
  });

  test('getImagesForPeriod exists', () async {
    expect(FlutterGalleryPlugin.getImagesForPeriod, isA<Function>());
  });
}
