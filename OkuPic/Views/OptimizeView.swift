import SwiftUI
import PhotosUI

struct OptimizeView: View {
    let destination: Destination

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var originalData: Data?
    @State private var metadataItems: [MetadataItem] = []
    @State private var result: OptimizationResult?
    @State private var isProcessing = false
    @State private var showSaveAlert = false
    @State private var saveMessage = ""
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 送信先情報
                destinationHeader

                if let result {
                    // 結果表示
                    resultSection(result)
                } else if let image = selectedImage {
                    // 写真選択済み → プレビュー + メタデータ + 最適化ボタン
                    previewSection(image)
                } else {
                    // 写真未選択
                    photoPickerPlaceholder
                }

                // 写真選択ボタン（結果表示時は非表示）
                if result == nil {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("写真を選択", systemImage: "photo.on.rectangle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("\(destination.name)用に最適化")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            loadImage(from: newItem)
        }
        .alert("保存", isPresented: $showSaveAlert) {
            Button("OK") {}
        } message: {
            Text(saveMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let result {
                ShareSheet(items: [result.optimizedImage])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - 送信先ヘッダー

    private var destinationHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: destination.icon)
                .font(.title2)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(destination.name)
                    .font(.headline)
                Text("最大\(ImageCompressor.formatFileSize(destination.maxFileSize)) / 長辺\(destination.maxLongEdge)px")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - 写真未選択時のプレースホルダー

    private var photoPickerPlaceholder: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 250)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("タップして写真を選択")
                            .foregroundColor(.gray)
                    }
                }
        }
        .padding(.horizontal)
    }

    // MARK: - プレビュー + メタデータ + 最適化ボタン

    private func previewSection(_ image: UIImage) -> some View {
        VStack(spacing: 16) {
            // 画像プレビュー
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .cornerRadius(12)
                .padding(.horizontal)

            // 元サイズ表示
            if let data = originalData {
                Text("元サイズ: \(ImageCompressor.formatFileSize(data.count))")
                    .foregroundColor(.secondary)
            }

            // メタデータプレビュー
            MetadataPreviewView(items: metadataItems, destination: destination)
                .padding(.horizontal)

            // 最適化ボタン
            Button(action: optimize) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Label("\(destination.name)用に最適化", systemImage: "bolt.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(isProcessing)
            .padding(.horizontal)
        }
    }

    // MARK: - 結果表示

    private func resultSection(_ result: OptimizationResult) -> some View {
        VStack(spacing: 16) {
            // 最適化後プレビュー
            Image(uiImage: result.optimizedImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .cornerRadius(12)
                .padding(.horizontal)

            // サイズ比較カード
            VStack(spacing: 12) {
                HStack {
                    Text("元サイズ")
                    Spacer()
                    Text(ImageCompressor.formatFileSize(result.originalSize))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("最適化後")
                    Spacer()
                    Text(ImageCompressor.formatFileSize(result.optimizedSize))
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }

                Divider()

                HStack {
                    Text("削減率")
                    Spacer()
                    Text(String(format: "%.1f%%", result.reductionRate))
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }

                // リサイズ情報
                if result.wasResized {
                    Divider()
                    HStack {
                        Text("解像度")
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(Int(result.originalDimensions.width))×\(Int(result.originalDimensions.height))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("→ \(Int(result.optimizedDimensions.width))×\(Int(result.optimizedDimensions.height))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }

                // メタデータ削除情報
                if result.strippedGPS || result.strippedAllMetadata {
                    Divider()
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                        Text(result.strippedAllMetadata ? "全メタデータを削除しました" : "位置情報を削除しました")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)

            // アクションボタン
            VStack(spacing: 12) {
                Button(action: saveToPhotoLibrary) {
                    Label("カメラロールに保存", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: { showShareSheet = true }) {
                    Label("共有", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: reset) {
                    Label("別の写真を最適化", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Actions

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        result = nil
        item.loadTransferable(type: Data.self) { transferResult in
            DispatchQueue.main.async {
                switch transferResult {
                case .success(let data):
                    if let data, let uiImage = UIImage(data: data) {
                        self.originalData = data
                        self.selectedImage = uiImage
                        self.metadataItems = MetadataManager.formatMetadataForDisplay(from: data)
                    }
                case .failure:
                    break
                }
            }
        }
    }

    private func optimize() {
        guard let image = selectedImage, let data = originalData else { return }
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let optimized = ImageOptimizer.optimize(image: image, originalData: data, destination: destination)
            DispatchQueue.main.async {
                self.result = optimized
                self.isProcessing = false
            }
        }
    }

    private func saveToPhotoLibrary() {
        guard let result else { return }
        UIImageWriteToSavedPhotosAlbum(result.optimizedImage, nil, nil, nil)
        saveMessage = "カメラロールに保存しました"
        showSaveAlert = true
    }

    private func reset() {
        selectedItem = nil
        selectedImage = nil
        originalData = nil
        metadataItems = []
        result = nil
    }
}

// 共有シート
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
