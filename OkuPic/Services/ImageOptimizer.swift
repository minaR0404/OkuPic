import UIKit
import ImageIO

struct ImageOptimizer {

    /// 送信先プリセットに基づいて画像を最適化
    static func optimize(image: UIImage, originalData: Data, destination: Destination) -> OptimizationResult? {
        let originalSize = originalData.count
        let originalDimensions = CGSize(width: image.size.width, height: image.size.height)

        // Step 1: リサイズ（必要な場合のみ）
        let resizedImage = resizeIfNeeded(image, maxLongEdge: CGFloat(destination.maxLongEdge))
        let wasResized = resizedImage.size != image.size
        let optimizedDimensions = CGSize(width: resizedImage.size.width, height: resizedImage.size.height)

        // Step 2: JPEG圧縮（ファイルサイズ制限内に収まるよう調整）
        guard let compressedData = compressToFit(
            image: resizedImage,
            targetQuality: destination.jpegQuality,
            maxFileSize: destination.maxFileSize
        ) else {
            return nil
        }

        // Step 3: メタデータ処理
        let finalData: Data
        if destination.stripAllMetadata || destination.stripGPS {
            finalData = MetadataManager.stripMetadata(
                from: compressedData,
                stripGPS: destination.stripGPS,
                stripAll: destination.stripAllMetadata
            ) ?? compressedData
        } else {
            finalData = compressedData
        }

        guard let optimizedImage = UIImage(data: finalData) else {
            return nil
        }

        let hasGPS = MetadataManager.readMetadata(from: originalData)[kCGImagePropertyGPSDictionary as String] != nil

        return OptimizationResult(
            originalSize: originalSize,
            optimizedSize: finalData.count,
            optimizedData: finalData,
            optimizedImage: optimizedImage,
            wasResized: wasResized,
            originalDimensions: originalDimensions,
            optimizedDimensions: optimizedDimensions,
            strippedGPS: destination.stripGPS && hasGPS,
            strippedAllMetadata: destination.stripAllMetadata
        )
    }

    /// 長辺がmaxLongEdgeを超える場合にリサイズ（アスペクト比維持）
    private static func resizeIfNeeded(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let longEdge = max(image.size.width, image.size.height)
        guard longEdge > maxLongEdge else { return image }

        let scale = maxLongEdge / longEdge
        let newSize = CGSize(
            width: round(image.size.width * scale),
            height: round(image.size.height * scale)
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// ファイルサイズ制限内に収まるようJPEG品質を調整して圧縮
    private static func compressToFit(image: UIImage, targetQuality: CGFloat, maxFileSize: Int) -> Data? {
        // まず指定品質で圧縮
        guard var data = image.jpegData(compressionQuality: targetQuality) else {
            return nil
        }

        // サイズ制限内ならそのまま返す
        if data.count <= maxFileSize {
            return data
        }

        // 品質を段階的に下げて再圧縮
        var quality = targetQuality - 0.1
        while quality >= 0.1 && data.count > maxFileSize {
            guard let newData = image.jpegData(compressionQuality: quality) else { break }
            data = newData
            quality -= 0.1
        }

        return data
    }
}
