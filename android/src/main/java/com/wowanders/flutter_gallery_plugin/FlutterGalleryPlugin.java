package com.wowanders.flutter_gallery_plugin;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;

import com.karumi.dexter.Dexter;
import com.karumi.dexter.PermissionToken;
import com.karumi.dexter.listener.PermissionDeniedResponse;
import com.karumi.dexter.listener.PermissionGrantedResponse;
import com.karumi.dexter.listener.PermissionRequest;
import com.karumi.dexter.listener.single.PermissionListener;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterGalleryPlugin */
public class FlutterGalleryPlugin implements MethodCallHandler {
  private static final String METHOD_GET_ALL = "getAllImages";
  private static final String METHOD_GET_FOR_PERIOD = "getImagesForPeriod";
  private static final String ARGUMENT_PERIOD_START = "startPeriod";
  private static final String ARGUMENT_PERIOD_END = "endPeriod";

  private Activity activity;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_gallery_plugin");
    channel.setMethodCallHandler(new FlutterGalleryPlugin(registrar.activity(), channel, registrar));
  }

  private FlutterGalleryPlugin(Activity activity, MethodChannel methodChannel, Registrar registrar) {
    this.activity = activity;
    methodChannel.setMethodCallHandler(this);
  }


  @Override
  public void onMethodCall(MethodCall call, Result result) {

    switch (call.method) {
      case METHOD_GET_ALL:
        checkPermissionAndGetAllImages(result, activity);
        break;
      case METHOD_GET_FOR_PERIOD:
        long startPeriod = call.hasArgument(ARGUMENT_PERIOD_START)
                ? (long) call.argument(ARGUMENT_PERIOD_START)
                : 0L;

        long endPeriod = call.hasArgument(ARGUMENT_PERIOD_END)
                ? (long) call.argument(ARGUMENT_PERIOD_END)
                : System.currentTimeMillis();
        checkPermissionAndQueryImagesForPeriod(result,
                activity, startPeriod, endPeriod);
        break;
      default:
        result.notImplemented();

    }
  }


  private void checkPermissionAndGetAllImages(final Result result, final Activity activity) {
    Dexter.withActivity(activity)
            .withPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            .withListener(new PermissionListener() {
              @Override
              public void onPermissionGranted(PermissionGrantedResponse response) {
                result.success(getAllImageList(activity));
              }

              @Override
              public void onPermissionDenied(PermissionDeniedResponse response) {

                AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                builder.setTitle("We need this permission");
                builder.setCancelable(false);
                builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                  public void onClick(DialogInterface dialog, int id) {
                    dialog.cancel();
                    Intent intent = new Intent();
                    intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                    intent.setData(uri);
                    activity.startActivity(intent);

                  }
                });
                builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                  public void onClick(DialogInterface dialog, int id) {
                    result.error("Permission Denied", null, null);
                    dialog.cancel();
                  }
                });
                AlertDialog alert = builder.create();
                alert.show();


              }

              @Override
              public void onPermissionRationaleShouldBeShown(PermissionRequest permission, final PermissionToken token) {

                AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                builder.setMessage("This permission is needed for use this features of the app so please, allow it!");
                builder.setTitle("We need this permission");
                builder.setCancelable(false);
                builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                  public void onClick(DialogInterface dialog, int id) {
                    dialog.cancel();
                    token.continuePermissionRequest();

                  }
                });
                builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                  public void onClick(DialogInterface dialog, int id) {
                    dialog.cancel();
                    token.cancelPermissionRequest();
                    result.error("Permission Denied", null, null);
                  }
                });
                AlertDialog alert = builder.create();
                alert.show();
              }
            }).check();

  }


  private ArrayList<String> getAllImageList(Activity activity) {

    ArrayList<String> allImageList = new ArrayList<>();

    Uri uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    String[] projection = {MediaStore.Images.ImageColumns.DATA,
            MediaStore.Images.ImageColumns.DISPLAY_NAME,
            MediaStore.Images.ImageColumns.DATE_ADDED,
            MediaStore.Images.ImageColumns.TITLE};
    Cursor c = activity.getContentResolver().query(uri, projection, null, null, null);
    if (c != null) {
      while (c.moveToNext()) {
        Log.e("", "getAllImageList: " + c.getString(0));
        allImageList.add(c.getString(0));
      }
      c.close();
    }
    return allImageList;
  }

  private void checkPermissionAndQueryImagesForPeriod(final Result result,
                                                      final Activity activity,
                                                      final long startPeriod,
                                                      final long endPeriod) {
    Dexter.withActivity(activity)
            .withPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
            .withListener(new PermissionListener() {
              @Override
              public void onPermissionGranted(PermissionGrantedResponse response) {
                result.success(getImagesForPeriod(activity, startPeriod, endPeriod));
              }

              @Override
              public void onPermissionDenied(PermissionDeniedResponse response) {
                result.error("Permission Denied", null, null);
              }

              @Override
              public void onPermissionRationaleShouldBeShown(PermissionRequest permission, PermissionToken token) {
                result.error("Permission Denied", null, null);
              }
            }).check();
  }

  private ArrayList<String> getImagesForPeriod(Activity activity,
                                               long startPeriod,
                                               long endPeriod) {
    ArrayList<String> imagesList = new ArrayList<>();

    Uri uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

    String[] projection = {MediaStore.Images.ImageColumns.DATA};

    String selection = MediaStore.Images.Media.DATE_TAKEN + ">=? and " + MediaStore.Images.Media.DATE_TAKEN + "<=?";

    String[] selectionArguments = new String[]{"" + startPeriod, "" + endPeriod};

    String sortOrder = MediaStore.Images.Media.DATE_TAKEN + " DESC";
    Cursor cursor = activity.getContentResolver().query(uri, projection, selection, selectionArguments, sortOrder);
    if (cursor != null) {
      while (cursor.moveToNext()) {
        Log.e("", "getImagesForPeriod: " + cursor.getString(0));
        imagesList.add(cursor.getString(0));
      }
      cursor.close();
    }
    return imagesList;
  }
}
