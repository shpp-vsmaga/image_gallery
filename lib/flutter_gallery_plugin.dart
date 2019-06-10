import 'dart:async';

import 'package:flutter/services.dart';

class FlutterGalleryPlugin {
  static const PATHS_CHANNEL = 'flutter_gallery_plugin/paths';
  static const ARGUMENT_PERIOD_START = 'startPeriod';
  static const ARGUMENT_PERIOD_END = 'endPeriod';

  static const _eventChannel = const EventChannel(PATHS_CHANNEL);

  static Stream<String> getPhotoPathsForPeriod(
    DateTime startPeriod,
    DateTime endPeriod,
  ) {
    Map<String, int> arguments = <String, int>{
      ARGUMENT_PERIOD_START: startPeriod.millisecondsSinceEpoch,
      ARGUMENT_PERIOD_END: endPeriod.millisecondsSinceEpoch,
    };

    return _eventChannel.receiveBroadcastStream(arguments).cast<String>();
  }
}
