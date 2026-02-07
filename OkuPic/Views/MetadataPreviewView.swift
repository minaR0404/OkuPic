import SwiftUI

struct MetadataPreviewView: View {
    let items: [MetadataItem]
    let destination: Destination

    var body: some View {
        if items.isEmpty {
            Text("メタデータなし")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("メタデータ")
                    .font(.headline)

                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.body)
                            .foregroundColor(iconColor(for: item))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.value)
                                .font(.subheadline)
                        }

                        Spacer()

                        // 削除/保持バッジ
                        if willBeStripped(item) {
                            Label("削除", systemImage: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                        } else {
                            Label("保持", systemImage: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)

                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private func willBeStripped(_ item: MetadataItem) -> Bool {
        if destination.stripAllMetadata { return true }
        if destination.stripGPS && item.category == .gps { return true }
        return false
    }

    private func iconColor(for item: MetadataItem) -> Color {
        willBeStripped(item) ? .red : .blue
    }
}
