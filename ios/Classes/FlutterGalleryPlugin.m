#import "FlutterGalleryPlugin.h"
#import <flutter_gallery_plugin/flutter_gallery_plugin-Swift.h>

@implementation FlutterGalleryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGalleryPlugin registerWithRegistrar:registrar];
}
@end
