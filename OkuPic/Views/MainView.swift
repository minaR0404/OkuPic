import SwiftUI

struct MainView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    VStack(spacing: 0) {
                        Image("HeaderIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)

                        Text("OkuPic")
                            .font(.system(size: 30, weight: .bold, design: .rounded))

                        Text("送り先を選んで、写真を最適化")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .padding(.top)

                    // 送信先グリッド
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Destination.allPresets) { destination in
                            NavigationLink(value: destination) {
                                DestinationCard(destination: destination)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Destination.self) { destination in
                OptimizeView(destination: destination)
            }
        }
    }
}

struct DestinationCard: View {
    let destination: Destination

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: destination.icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text(destination.name)
                .font(.headline)
                .foregroundColor(.primary)

            Text(destination.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    MainView()
}
