import SwiftUI

struct LaunchPadView: View {
    @EnvironmentObject private var controller: LaunchPadController
    @EnvironmentObject private var catalog: AppCatalog
    @State private var appeared = false

    private let columns = Array(repeating: GridItem(.fixed(100), spacing: 16), count: 10)

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Spacer()
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(catalog.apps) { app in
                        AppIconCell(app: app)
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
                Spacer()
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 1.12)
        }
        .onReceive(controller.$enteredFullScreen) { entered in
            guard entered, !appeared else { return }
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
        .onReceive(NotificationCenter.default.publisher(for: .launchPadWillHide)) { _ in
            withAnimation(.easeOut(duration: 0.18)) { appeared = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                controller.finishHide()
            }
        }
    }
}

struct AppIconCell: View {
    let app: AppItem

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 72, height: 72)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
            Text(app.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                .frame(width: 100)
        }
    }
}
