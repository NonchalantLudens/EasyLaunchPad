import AppKit
import SwiftUI

/// 图块按压状态的环境传递：按压效果只作用于图标本体（经典 Launchpad 样式）。
private struct TilePressedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var tilePressed: Bool {
        get { self[TilePressedKey.self] }
        set { self[TilePressedKey.self] = newValue }
    }
}

/// 图标按钮按下反馈：图标本体缩小变暗，抬起即恢复。
struct IconPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.tilePressed, configuration.isPressed)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
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
    var reportsGridOrigin: Bool = false
    /// 图块中心在页面坐标空间中的位置（换位后由父视图更新）。
    var slotCenterPage: CGPoint = .zero
    var onDragStarted: ((CGPoint) -> Void)? = nil
    var onDragMoved: ((CGPoint) -> Void)? = nil
    var onDragEnded: ((CGPoint) -> Void)? = nil

    @State private var icon: NSImage?
    @State private var cachedName: String?
    @State private var cachedHighlight: String?
    @State private var cachedAttributed: AttributedString?
    @State private var dragging = false
    /// 指针到图块中心的固定偏移：抓哪算哪，拖动全程保持。
    @State private var grabDelta: CGSize = .zero
    @State private var lastLocation: CGPoint = .zero
    @State private var followOffset: CGSize = .zero

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
        .offset(followOffset)
        .opacity(entered ? 1 : 0)
        .offset(y: entered ? 0 : 40)
        .scaleEffect(entered ? 1 : 0.85)
        .zIndex(isDragged ? 1 : 0)
        .animation(
            animationEnabled
                ? .spring(response: 0.28, dampingFraction: 0.8).delay(revealDelay)
                : nil,
            value: entered
        )
        .transition(.scale(scale: 0.6).combined(with: .opacity))
        // 拖动中的图块排除一切动画：布局瞬时到位，跟随偏移保证指针贴合
        .transaction { transaction in
            if isDragged { transaction.animation = nil }
        }
        .simultaneousGesture(dragGesture)
        .onChange(of: slotCenterPage) { _, newCenter in
            // 换位后布局位置变化，用当前指针位置重算偏移，抓取点保持不动
            guard dragging else { return }
            followOffset = followOffset(for: lastLocation, center: newCenter)
        }
        .task(id: app.id) {
            icon = await IconStore.shared.icon(for: app.url)
        }
    }

    private func followOffset(for location: CGPoint, center: CGPoint) -> CGSize {
        CGSize(
            width: location.x + grabDelta.width - center.x,
            height: location.y + grabDelta.height - center.y
        )
    }

    /// 首个图块上报自身在页面坐标空间中的原点，供命中测试定位网格。
    /// 各页布局一致，页面空间原点全页相同。
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
                if !dragging {
                    dragging = true
                    grabDelta = CGSize(
                        width: slotCenterPage.x - value.location.x,
                        height: slotCenterPage.y - value.location.y
                    )
                    onDragStarted?(value.location)
                }
                lastLocation = value.location
                followOffset = followOffset(for: value.location, center: slotCenterPage)
                onDragMoved?(value.location)
            }
            .onEnded { value in
                guard dragging else { return }
                dragging = false
                followOffset = .zero
                onDragEnded?(value.location)
            }
    }

    @Environment(\.tilePressed) private var tilePressed

    @ViewBuilder
    private var iconView: some View {
        if let icon {
            Image(nsImage: icon)
                .resizable()
                .frame(width: size.iconPoint, height: size.iconPoint)
                .scaleEffect(tilePressed ? 0.88 : 1)
                .opacity(tilePressed ? 0.55 : 1)
                .animation(.easeOut(duration: 0.12), value: tilePressed)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        } else {
            RoundedRectangle(cornerRadius: size.iconCornerRadius - 4, style: .continuous)
                .fill(.white.opacity(0.12))
                .frame(width: size.iconPoint, height: size.iconPoint)
        }
    }
}
