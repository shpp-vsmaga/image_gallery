import Flutter
import UIKit
import Photos

public class SwiftFlutterGalleryPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let stream = FlutterEventChannel(name: "flutter_gallery_plugin/paths", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterGalleryPlugin()
        stream.setStreamHandler(instance)
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        let args = arguments as! [String: Double]
        let startDate = Date(timeIntervalSince1970: args["startPeriod"]! / 1000)
        let endDate = Date(timeIntervalSince1970: args["endPeriod"]! / 1000)

        self.getPhotoPaths(startDate: startDate, endDate: endDate)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func onPathResolved(path: String) {
        guard let eventSink = eventSink else {
            return
        }

        eventSink(path)
    }

    public func closeSink() {
        guard let eventSink = eventSink else {
            return
        }

        eventSink(nil)
        self.eventSink = nil
    }

    func getPhotoPaths(startDate: Date, endDate: Date) {
        DispatchQueue.main.async {
            let assets = self.fetchPhotos()
            assets.enumerateObjects({
                (asset, index, stop) in
                    if (asset.creationDate! < startDate) {
                        self.closeSink()
                        stop.pointee = false
                    }

                    if (asset.creationDate! >= startDate && asset.creationDate! <= endDate) {
                        self.getPhotoPath(
                            asset: asset,
                            callback: {
                                (path) in self.onPathResolved(path: path)
                            }
                        )
                    }
            })
        }
    }

    func fetchPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
    }

    func getPhotoPath(asset: PHAsset, callback: @escaping (String)->()) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()

        options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        options.resizeMode = PHImageRequestOptionsResizeMode.exact

        imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 512, height: 512),
            contentMode: PHImageContentMode.aspectFit,
            options: options,
            resultHandler: {
                (image, info) in
                callback(self.storeThumbnail(image: image))
            }
        )
    }

    func storeThumbnail(image: UIImage?) -> String {
        let fileName = String(format: "image_picker_%@.jpg", ProcessInfo.processInfo.globallyUniqueString)
        let filePath = NSString.path(withComponents: [NSTemporaryDirectory(), fileName])

        FileManager.default.createFile(
            atPath: filePath,
            contents: image?.jpegData(compressionQuality: CGFloat(0.8)),
            attributes: [:]
        )

        return filePath
    }
}
