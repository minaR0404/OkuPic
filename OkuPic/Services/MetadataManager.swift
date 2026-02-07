import ImageIO
import Foundation

struct MetadataManager {

    /// 画像データからメタデータを読み取る
    static func readMetadata(from data: Data) -> [String: Any] {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return [:]
        }
        return properties
    }

    /// メタデータを選択的に除去して画像データを再書き出し
    static func stripMetadata(from data: Data, stripGPS: Bool, stripAll: Bool) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let uti = CGImageSourceGetType(source) else {
            return nil
        }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, uti, 1, nil) else {
            return nil
        }

        var properties = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]) ?? [:]

        if stripAll {
            // 全メタデータ削除: EXIF, GPS, TIFF, IPTC等を除去
            properties.removeValue(forKey: kCGImagePropertyExifDictionary as String)
            properties.removeValue(forKey: kCGImagePropertyGPSDictionary as String)
            properties.removeValue(forKey: kCGImagePropertyTIFFDictionary as String)
            properties.removeValue(forKey: kCGImagePropertyIPTCDictionary as String)
            properties.removeValue(forKey: kCGImagePropertyMakerAppleDictionary as String)
        } else if stripGPS {
            // GPS情報のみ削除
            properties.removeValue(forKey: kCGImagePropertyGPSDictionary as String)
        }

        CGImageDestinationAddImageFromSource(destination, source, 0, properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return mutableData as Data
    }

    /// メタデータをUI表示用にフォーマット
    static func formatMetadataForDisplay(from data: Data) -> [MetadataItem] {
        let metadata = readMetadata(from: data)
        var items: [MetadataItem] = []

        // GPS情報
        if let gps = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double
            let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double
            if let lat, let lon {
                items.append(MetadataItem(
                    label: "位置情報",
                    value: String(format: "%.4f, %.4f", lat, lon),
                    icon: "location.fill",
                    category: .gps
                ))
            } else {
                items.append(MetadataItem(
                    label: "位置情報",
                    value: "あり",
                    icon: "location.fill",
                    category: .gps
                ))
            }
        }

        // EXIF情報
        if let exif = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            if let dateTime = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                items.append(MetadataItem(
                    label: "撮影日時",
                    value: dateTime,
                    icon: "calendar",
                    category: .exif
                ))
            }
            if let focalLength = exif[kCGImagePropertyExifFocalLength as String] as? Double {
                items.append(MetadataItem(
                    label: "焦点距離",
                    value: String(format: "%.0fmm", focalLength),
                    icon: "camera.metering.center.weighted",
                    category: .exif
                ))
            }
        }

        // TIFF情報（カメラ情報）
        if let tiff = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            if let make = tiff[kCGImagePropertyTIFFMake as String] as? String,
               let model = tiff[kCGImagePropertyTIFFModel as String] as? String {
                items.append(MetadataItem(
                    label: "カメラ",
                    value: "\(make) \(model)",
                    icon: "camera",
                    category: .device
                ))
            }
        }

        // 画像サイズ
        if let width = metadata[kCGImagePropertyPixelWidth as String] as? Int,
           let height = metadata[kCGImagePropertyPixelHeight as String] as? Int {
            items.append(MetadataItem(
                label: "解像度",
                value: "\(width) × \(height)",
                icon: "aspectratio",
                category: .image
            ))
        }

        return items
    }
}

struct MetadataItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
    let category: MetadataCategory
}

enum MetadataCategory {
    case gps
    case exif
    case device
    case image
}
