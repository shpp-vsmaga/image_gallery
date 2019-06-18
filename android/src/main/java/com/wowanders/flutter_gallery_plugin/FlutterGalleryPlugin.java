package com.wowanders.flutter_gallery_plugin;

import android.database.Cursor;
import android.provider.MediaStore;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterGalleryPlugin
 */
public class FlutterGalleryPlugin implements EventChannel.StreamHandler {
  private static final String ARGUMENT_PERIOD_START = "startPeriod";
  private static final String ARGUMENT_PERIOD_END = "endPeriod";

  private final Registrar registrar;
  private EventChannel.EventSink events;

  public static void registerWith(Registrar registrar) {
    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "flutter_gallery_plugin/paths");
    final FlutterGalleryPlugin instance = new FlutterGalleryPlugin(registrar);
    eventChannel.setStreamHandler(instance);
  }

  private FlutterGalleryPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onListen(Object args, EventChannel.EventSink events) {
    this.events = events;

    Map arguments = args instanceof Map ? (Map) args : new HashMap();

    long startPeriod = arguments.containsKey(ARGUMENT_PERIOD_START)
      ? (long) arguments.get(ARGUMENT_PERIOD_START)
      : 0L;

    long endPeriod = arguments.containsKey(ARGUMENT_PERIOD_END)
      ? (long) arguments.get(ARGUMENT_PERIOD_END)
      : System.currentTimeMillis();

    getPhotoPaths(startPeriod, endPeriod);
  }

  @Override
  public void onCancel(Object args) {
    this.events = null;
  }

  private void getPhotoPaths(long startPeriod, long endPeriod) {
    String photoDate = MediaStore.Images.Media.DATE_TAKEN;

    Cursor cursor = registrar.activity().getContentResolver().query(
      MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
      new String[]{MediaStore.Images.ImageColumns.DATA},
      photoDate + ">=? and " + photoDate + "<=?",
      new String[]{"" + startPeriod, "" + endPeriod},
      photoDate + " DESC"
    );

    if (cursor != null) {
      while (cursor.moveToNext()) {
        events.success(cursor.getString(0));
      }
      events.endOfStream();
      cursor.close();
    }
  }
}
