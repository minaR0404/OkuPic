import UIKit

struct ImageCompressor {

    /// 画像を指定した品質で圧縮
    /// - Parameters:
    ///   - image: 元画像
    ///   - quality: 圧縮品質（0.0〜1.0）
    /// - Returns: 圧縮後のデータ
    static func compress(_ image: UIImage, quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }

    /// データサイズを読みやすい形式にフォーマット
    static func formatFileSize(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        }
        let mb = kb / 1024
        return String(format: "%.2f MB", mb)
    }

    /// 圧縮率を計算
    static func compressionRatio(original: Int, compressed: Int) -> Double {
        guard original > 0 else { return 0 }
        return (1.0 - Double(compressed) / Double(original)) * 100
    }
}
