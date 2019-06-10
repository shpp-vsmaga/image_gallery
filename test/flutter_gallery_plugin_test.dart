import 'package:flutter_gallery_plugin/flutter_gallery_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getPhotoPathsForPeriod exists', () async {
    expect(FlutterGalleryPlugin.getPhotoPathsForPeriod, isA<Function>());
  });
}
