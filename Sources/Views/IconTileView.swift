import AppKit
import SwiftUI

/// 图标按钮按下反馈：按下瞬间变暗缩小，抬起即恢复。
struct IconPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct IconTileView: View {
    let app: AppItem
    let isSelected: Bool
    let highlight: String
    let jiggle: Double
    let deleteMode: Bool
    let size: IconSizeLevel
    let entered: Bool
    let revealDelay: Double
    let animationEnabled: Bool
    let action: () -> Void
    let onBadge: () -> Void

    // 拖拽排序（未启用时回调为 nil，不参与布局）
    var dragSpaceName: String? = nil
    var isDragged: Bool = false
    var dragOffset: CGSize = .zero
    var reportsGridOrigin: Bool = false
    var onDragStarted: (() -> Void)? = nil
    var onDragMoved: ((CGPoint) -> Void)? = nil
    var onDragEnded: ((CGPoint) -> Void)? = nil

    @State private var icon: NSImage?
    @State private var cachedName: String?
    @State private var cachedHighlight: String?
    @State private var cachedAttributed: AttributedString?
    @State private var dragging = false

    private var attributedName: AttributedString {
        if let cachedAttributed, cachedName == app.name, cachedHighlight == highlight {
            return cachedAttributed
        }
        var result = AttributedString(app.name)
        result.font = .system(size: 13, weight: .medium)
        result.foregroundColor = .white
        if !highlight.isEmpty, let range = result.range(of: highlight, options: [.caseInsensitive]) {
            result[range].font = .system(size: 13, weight: .bold)
            result[range].backgroundColor = .white.opacity(0.25)
        }
        cachedAttributed = result
        cachedName = app.name
        cachedHighlight = highlight
        return result
    }

    var body: some View {
        ZStack {
            Button(action: deleteMode ? {} : action) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: size.iconCornerRadius, style: .continuous)
                            .fill(.white.opacity(isSelected ? 0.25 : 0))
                            .frame(width: size.ringPoint, height: size.ringPoint)
                            .scaleEffect(isSelected ? 1 : 0.9)
                            .animation(.spring(duration: 0.25), value: isSelected)
                        iconView
                    }
                    Text(attributedName)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
                        .frame(width: size.nameWidth, height: 34)
                }
                .frame(width: size.tileWidth, height: size.tileHeight)
                .contentShape(Rectangle())
                .compositingGroup()
            }
            .buttonStyle(IconPressStyle())
            .overlay(alignment: .topTrailing) {
                if deleteMode {
                    Button(action: onBadge) {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white, .red)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, size.badgeTrailing)
                    .padding(.top, size.badgeTop)
                }
            }
        }
        .background { gridOriginReader }
        .rotationEffect(.degrees(jiggle))
        .offset(x: jiggle * 0.55)
        .offset(dragOffset)
        .opacity(entered ? 1 : 0)
        .offset(y: entered ? 0 : 40)
        .scaleEffect(entered ? 1 : 0.85)
        .scaleEffect(isDragged ? 1.08 : 1)
        .zIndex(isDragged ? 1 : 0)
        .animation(
            animationEnabled
                ? .spring(response: 0.28, dampingFraction: 0.8).delay(revealDelay)
                : nil,
            value: entered
        )
        .transition(.scale(scale: 0.6).combined(with: .opacity))
        .simultaneousGesture(dragGesture)
        .task(id: app.id) {
            icon = await IconStore.shared.icon(for: app.url)
        }
    }

    /// 首个图块上报自身在页面坐标空间中的原点，供命中测试定位网格。
    @ViewBuilder
    private var gridOriginReader: some View {
        if reportsGridOrigin, let name = dragSpaceName {
            GeometryReader { geo in
                Color.clear.preference(
                    key: GridOriginKey.self,
                    value: geo.frame(in: .named(name)).origin
                )
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .named(dragSpaceName ?? "gridPage"))
            .onChanged { value in
                guard onDragStarted != nil else { return }
                if dragging {
                    onDragMoved?(value.location)
                } else {
                    dragging = true
                    onDragStarted?()
                }
            }
            .onEnded { value in
                guard dragging else { return }
                dragging = false
                onDragEnded?(value.location)
            }
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: size.iconPoint, height: size.iconPoint)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        } else {
            RoundedRectangle(cornerRadius: size.iconCornerRadius - 4, style: .continuous)
                .fill(.white.opacity(0.12))
                .frame(width: size.iconPoint, height: size.iconPoint)
        }
    }
}
