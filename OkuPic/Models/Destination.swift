import UIKit

struct Destination: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let maxFileSize: Int
    let maxLongEdge: Int
    let jpegQuality: CGFloat
    let stripGPS: Bool
    let stripAllMetadata: Bool

    static let allPresets: [Destination] = [
        Destination(
            name: "LINE",
            icon: "message.fill",
            description: "LINEで送る写真を最適化",
            maxFileSize: 20 * 1024 * 1024,
            maxLongEdge: 1920,
            jpegQuality: 0.85,
            stripGPS: true,
            stripAllMetadata: false
        ),
        Destination(
            name: "X (Twitter)",
            icon: "at",
            description: "X投稿用に最適化",
            maxFileSize: 5 * 1024 * 1024,
            maxLongEdge: 2048,
            jpegQuality: 0.85,
            stripGPS: true,
            stripAllMetadata: false
        ),
        Destination(
            name: "Instagram",
            icon: "camera.fill",
            description: "Instagram投稿用に最適化",
            maxFileSize: 8 * 1024 * 1024,
            maxLongEdge: 1440,
            jpegQuality: 0.90,
            stripGPS: true,
            stripAllMetadata: false
        ),
        Destination(
            name: "メルカリ",
            icon: "bag.fill",
            description: "メルカリ出品写真を最適化",
            maxFileSize: 5 * 1024 * 1024,
            maxLongEdge: 1280,
            jpegQuality: 0.80,
            stripGPS: true,
            stripAllMetadata: false
        ),
        Destination(
            name: "メール",
            icon: "envelope.fill",
            description: "メール添付用に軽量化",
            maxFileSize: 2 * 1024 * 1024,
            maxLongEdge: 1600,
            jpegQuality: 0.75,
            stripGPS: true,
            stripAllMetadata: false
        ),
        Destination(
            name: "Web",
            icon: "globe",
            description: "Webアップロード用に最適化",
            maxFileSize: 500 * 1024,
            maxLongEdge: 1200,
            jpegQuality: 0.70,
            stripGPS: true,
            stripAllMetadata: true
        ),
    ]
}

struct OptimizationResult {
    let originalSize: Int
    let optimizedSize: Int
    let optimizedData: Data
    let optimizedImage: UIImage
    let wasResized: Bool
    let originalDimensions: CGSize
    let optimizedDimensions: CGSize
    let strippedGPS: Bool
    let strippedAllMetadata: Bool

    var reductionRate: Double {
        guard originalSize > 0 else { return 0 }
        return (1.0 - Double(optimizedSize) / Double(originalSize)) * 100
    }
}
