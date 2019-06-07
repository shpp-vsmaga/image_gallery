import 'dart:async';

import 'package:flutter/services.dart';

class FlutterGalleryPlugin {
  static const MethodChannel _channel = const MethodChannel(
    'flutter_gallery_plugin',
  );
  static const String METHOD_GET_ALL = 'getAllImages';
  static const String METHOD_GET_FOR_PERIOD = 'getImagesForPeriod';
  static const String ARGUMENT_PERIOD_START = 'startPeriod';
  static const String ARGUMENT_PERIOD_END = 'endPeriod';

  static Future<List<String>> getAllImages() async {
    List<dynamic> list = await _channel.invokeMethod(METHOD_GET_ALL);
    return list.map((dynamic item) => item.toString()).toList();
  }

  static Future<List<String>> getImagesForPeriod(
    DateTime startPeriod,
    DateTime endPeriod,
  ) async {
    Map<String, dynamic> arguments = <String, dynamic>{
      ARGUMENT_PERIOD_START: startPeriod.millisecondsSinceEpoch,
      ARGUMENT_PERIOD_END: endPeriod.millisecondsSinceEpoch,
    };

    List<dynamic> list = await _channel.invokeMethod(
      METHOD_GET_FOR_PERIOD,
      arguments,
    );

    return list.map((dynamic item) => item.toString()).toList();
  }
}
