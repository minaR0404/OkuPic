import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8

    var body: some View {
        if isActive {
            MainView()
        } else {
            VStack(spacing: 16) {
                Image("HeaderIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("OkuPic")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 1.0
                    scale = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
