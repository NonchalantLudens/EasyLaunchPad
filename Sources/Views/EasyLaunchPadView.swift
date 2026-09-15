import AppKit
import Carbon.HIToolbox
import SwiftUI

struct EasyLaunchPadView: View {
    @EnvironmentObject private var controller: EasyLaunchPadController
    @EnvironmentObject private var catalog: AppCatalog
    @EnvironmentObject private var settings: EasyLaunchPadSettings
    @State private var appeared = false
    @State private var jigglePhase: Double = 0
    @State private var jiggleTimer: Timer?
    @State private var selection = GridSelection.zero
    @State private var pages: [[AppItem]] = []
    @State private var searchText = ""
    @State private var pendingActionApp: AppItem?
    @State private var pinchScale: CGFloat = 1
    @State private var pinchAccum: CGFloat = 0
    @State private var swipeDelta: CGFloat = 0
    @State private var lastWheelSwitch = Date.distantPast
    // 拖拽排序状态（跟随偏移由被拖图块局部管理，父视图只在换位/翻页时更新）
    @State private var reorderList: [AppItem]?
    @State private var dragAppID: String?
    @State private var gridOrigin: CGPoint = .zero
    @State private var pageFlipWork: DispatchWorkItem?
    @State private var pendingFlipDirection: GridDirection?
    @State private var lastDragEnd = Date.distantPast
    @FocusState private var searchFocused: Bool

    private var filteredApps: [AppItem] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return catalog.apps }
        return catalog.apps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    /// 背景模糊强度与透明度直接对应：透明度 100% 时零模糊、桌面原样透出。
    private var blurIntensity: Double {
        min(1, (1 - settings.backgroundTransparency) * 1.4)
    }

    private var dimOpacity: Double {
        (1 - settings.backgroundTransparency) * 0.55
    }

    var body: some View {
        ZStack {
            // behindWindow 毛玻璃：GPU 取窗口后面的桌面实时模糊，
            // 强度随透明度变化（100% 时无模糊），不读壁纸文件、无权限弹窗
            DesktopBlurBackground(intensity: blurIntensity)
                .ignoresSafeArea()
            LinearGradient(
                colors: [
                    .black.opacity(dimOpacity),
                    .black.opacity(dimOpacity * 0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2), value: settings.backgroundTransparency)

            VStack(spacing: 0) {
                SearchBarView(text: $searchText, focused: $searchFocused)
                    .padding(.top, 56)
                Spacer()
                    .frame(height: 60)
                GridPagesView(
                    pages: pages,
                    selection: selection,
                    columns: controller.gridLayout.columns,
                    highlight: searchText.trimmingCharacters(in: .whitespaces),
                    deleteMode: controller.deleteMode,
                    jigglePhase: jigglePhase,
                    size: settings.iconSize,
                    entered: appeared || !settings.iconEntryAnimation,
                    animationEnabled: settings.iconEntryAnimation,
                    dragEnabled: searchText.trimmingCharacters(in: .whitespaces).isEmpty,
                    dragAppID: dragAppID,
                    gridOriginPage: gridOrigin,
                    onGridOrigin: { gridOrigin = $0 },
                    onDragStart: handleDragStart,
                    onDragMove: handleDragMove,
                    onDragEnd: handleDragEnd,
                    onSelect: open,
                    onBadge: { pendingActionApp = $0 }
                )
                .frame(maxHeight: .infinity)
                Spacer()
                    .frame(height: 90)
            }
            .overlay(alignment: .bottom) {
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty, pages.count > 1 {
                    PageDotsView(
                        pageCount: pages.count,
                        currentPage: selection.pageIndex,
                        onSelect: { index in
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selection = GridNavigation.page(index, pageCounts: pages.map(\.count))
                            }
                        }
                    )
                    .padding(.bottom, 18)
                }
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 * pinchScale : 0.98 * pinchScale)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            controller.hide()
        }
        .onAppear {
            rebuildPages()
            controller.keyHandler = { event in
                handleKey(event)
            }
            controller.gestureHandler = { event in
                handleGesture(event)
            }
            withAnimation(.easeOut(duration: 0.2)) {
                appeared = true
            }
        }
        .onDisappear {
            controller.keyHandler = nil
            controller.gestureHandler = nil
            jiggleTimer?.invalidate()
            jiggleTimer = nil
            pageFlipWork?.cancel()
            pageFlipWork = nil
            pendingFlipDirection = nil
            dragAppID = nil
            reorderList = nil
        }
        .onChange(of: controller.deleteMode) { _, enabled in
            jiggleTimer?.invalidate()
            jiggleTimer = nil
            jigglePhase = 0
            if enabled {
                // 20fps 抖动驱动，降低全网格重渲染开销
                jiggleTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    jigglePhase += 0.7
                }
            }
        }
        .onReceive(catalog.$apps) { apps in
            // 拖拽进行中不响应外部刷新，避免打断拖拽中的临时顺序
            guard dragAppID == nil else { return }
            // @Published 在 willSet 发布：此时 catalog.apps 仍是旧值，
            // 必须用传入的新值重建页面；withAnimation 让其余图标滑动补位
            withAnimation(.easeInOut(duration: 0.25)) {
                rebuildPages(apps: apps)
            }
        }
        .onReceive(controller.$gridLayout) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                rebuildPages()
            }
        }
        .onChange(of: searchText) { _, _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                rebuildPages()
            }
        }
        .alert(
            "处理应用",
            isPresented: Binding(
                get: { pendingActionApp != nil },
                set: { if !$0 { pendingActionApp = nil } }
            ),
            presenting: pendingActionApp
        ) { app in
            Button("从 EasyLaunchPad 隐藏") {
                catalog.hide(app)
            }
            Button("移到废纸篓", role: .destructive) {
                trash(app)
            }
            Button("取消", role: .cancel) {}
        } message: { app in
            Text("选择要执行的操作：\(app.name)")
        }
    }

    private func trash(_ app: AppItem) {
        guard let url = app.url else { return }
        if TrashService.trash(url) {
            catalog.removeManual(url)
            catalog.markTrashed(app)
        }
    }

    private func rebuildPages(apps: [AppItem]? = nil) {
        let source = apps ?? filteredApps
        pages = controller.gridLayout.pages(source)
        selection = GridNavigation.clamp(selection, pageCounts: pages.map(\.count))
    }

    private func open(_ app: AppItem) {
        // 拖拽刚结束的误触不触发启动；按压反馈由图块按下样式提供
        guard Date().timeIntervalSince(lastDragEnd) > 0.25 else { return }
        // 先淡出窗口再异步启动应用：目标应用启动慢或弹出对话框时，
        // 全屏遮罩立即消失，不会卡在屏幕上盖住其他窗口的提示
        controller.hide()
        guard let url = app.url else { return }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.open(url, configuration: configuration, completionHandler: nil)
    }

    private func openSelected() {
        guard !pages.isEmpty else { return }
        let page = pages[selection.pageIndex]
        guard page.indices.contains(selection.itemIndex) else { return }
        open(page[selection.itemIndex])
    }

    // MARK: - 图标拖拽排序

    private var gridGeometry: GridGeometry {
        GridGeometry(
            columns: controller.gridLayout.columns,
            tileWidth: settings.iconSize.tileWidth,
            tileHeight: settings.iconSize.tileHeight,
            spacing: settings.iconSize.spacing,
            origin: gridOrigin
        )
    }

    private func handleDragStart(_ app: AppItem, at location: CGPoint) {
        // 搜索过滤时列表不是完整集合，禁用拖拽排序
        guard searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let source = catalog.apps
        guard source.contains(where: { $0.id == app.id }) else { return }
        reorderList = source
        dragAppID = app.id
    }

    private func handleDragMove(_ app: AppItem, at location: CGPoint) {
        guard var list = reorderList, let dragID = dragAppID else { return }
        schedulePageFlip(at: location)
        let geo = gridGeometry
        let perPage = max(1, controller.gridLayout.perPage)
        guard let from = list.firstIndex(where: { $0.id == dragID }) else { return }
        // 命中其他槽位则换位：其余图块动画滑动补位；
        // 被拖图块通过 .transaction 排除动画，布局瞬时到位，
        // 加上跟随偏移后指针与图标始终贴合
        if let slot = geo.slotIndex(at: location, maxSlots: list.count) {
            let target = min(selection.pageIndex * perPage + slot, list.count - 1)
            if target != from {
                withAnimation(.easeInOut(duration: 0.18)) {
                    let item = list.remove(at: from)
                    list.insert(item, at: min(target, list.count))
                    reorderList = list
                    rebuildPages(apps: list)
                }
            }
        }
    }

    private func handleDragEnd(_ app: AppItem, at location: CGPoint) {
        cancelPageFlip()
        lastDragEnd = Date()
        guard let list = reorderList, dragAppID != nil else {
            dragAppID = nil
            reorderList = nil
            return
        }
        dragAppID = nil
        reorderList = nil
        // 落盘并发布新顺序；onReceive 会以动画重建页面
        catalog.applyOrder(list.map(\.id))
    }

    /// 拖到屏幕左右边缘停留时自动翻页（进入/离开边缘区域才重新排定，避免高频状态写入）。
    private func schedulePageFlip(at location: CGPoint) {
        let screenWidth = controller.currentScreen?.frame.width ?? 0
        let direction: GridDirection?
        if location.x < 60 {
            direction = .left
        } else if screenWidth > 0, location.x > screenWidth - 60 {
            direction = .right
        } else {
            direction = nil
        }
        guard direction != pendingFlipDirection else { return }
        cancelPageFlip()
        pendingFlipDirection = direction
        guard let direction else { return }
        let work = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.18)) {
                switchPage(direction)
            }
        }
        pageFlipWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: work)
    }

    private func cancelPageFlip() {
        pageFlipWork?.cancel()
        pageFlipWork = nil
        pendingFlipDirection = nil
    }

    private func move(_ direction: GridDirection) {
        selection = GridNavigation.move(
            direction,
            from: selection,
            pageCounts: pages.map(\.count),
            columns: controller.gridLayout.columns
        )
    }

    /// 直接切换页面（左右键 / 滑动手势）。
    private func switchPage(_ direction: GridDirection) {
        guard direction == .left || direction == .right else { return }
        let newPage = selection.pageIndex + (direction == .right ? 1 : -1)
        guard pages.indices.contains(newPage) else { return }
        selection.pageIndex = newPage
        selection.itemIndex = min(selection.itemIndex, max(0, pages[newPage].count - 1))
    }

    /// 滚轮切页带防抖：快速连续滚动只算一档，形成档位感。
    private func wheelSwitch(_ direction: GridDirection) {
        let now = Date()
        guard now.timeIntervalSince(lastWheelSwitch) > 0.2 else { return }
        lastWheelSwitch = now
        switchPage(direction)
    }

    private func handleKey(_ event: NSEvent) -> Bool {
        if searchFocused {
            if event.keyCode == UInt16(kVK_Escape) {
                if !searchText.isEmpty {
                    searchText = ""
                }
                searchFocused = false
                return true
            }
            return false
        }

        switch event.keyCode {
        case UInt16(kVK_LeftArrow):
            move(.left)
        case UInt16(kVK_RightArrow):
            move(.right)
        case UInt16(kVK_UpArrow):
            move(.up)
        case UInt16(kVK_DownArrow):
            move(.down)
        case UInt16(kVK_Home):
            selection = GridNavigation.page(0, pageCounts: pages.map(\.count))
        case UInt16(kVK_End):
            selection = GridNavigation.page(Int.max, pageCounts: pages.map(\.count))
        case UInt16(kVK_Return):
            openSelected()
        case UInt16(kVK_Escape):
            if !searchText.isEmpty {
                searchText = ""
            } else {
                controller.hide()
            }
        case UInt16(kVK_Delete), UInt16(kVK_ForwardDelete):
            return false
        case UInt16(kVK_ANSI_F):
            if event.modifierFlags.contains(.command) {
                searchFocused = true
            } else {
                return false
            }
        default:
            let modifiers = event.modifierFlags.intersection([.command, .control, .option])
            guard modifiers.isEmpty,
                  let chars = event.charactersIgnoringModifiers,
                  !chars.isEmpty else { return false }
            searchFocused = true
            searchText += chars
        }
        return true
    }

    private func handleGesture(_ event: NSEvent) -> Bool {
        switch event.type {
        case .swipe:
            guard settings.swipeEnabled else { return false }
            if abs(event.deltaX) > 0.5 {
                switchPage(event.deltaX < 0 ? .right : .left)
            }
            return true
        case .magnify:
            guard settings.pinchEnabled else { return false }
            handlePinch(event)
            return true
        case .scrollWheel:
            guard settings.swipeEnabled, event.momentumPhase == [] else { return false }
            if event.phase.contains(.began) {
                swipeDelta = 0
            }
            if event.phase.contains(.changed) {
                // 主轴向（水平或垂直）累积，鼠标滚轮以垂直为主
                swipeDelta += abs(event.scrollingDeltaX) >= abs(event.scrollingDeltaY)
                    ? event.scrollingDeltaX
                    : event.scrollingDeltaY
            }
            if event.phase.contains(.ended) {
                if abs(swipeDelta) > 50 {
                    wheelSwitch(swipeDelta < 0 ? .right : .left)
                }
                swipeDelta = 0
                return true
            }
            if event.phase == [] {
                // 离散滚轮（鼠标）：主轴向判定
                let dx = abs(event.scrollingDeltaX)
                let dy = abs(event.scrollingDeltaY)
                if max(dx, dy) > 5 {
                    let delta = dx >= dy ? event.scrollingDeltaX : event.scrollingDeltaY
                    wheelSwitch(delta < 0 ? .right : .left)
                }
                return true
            }
            return true
        default:
            return false
        }
    }

    private func handlePinch(_ event: NSEvent) {
        pinchAccum += event.magnification
        let target = min(max(1 + pinchAccum * 3, 0.5), 1.6)
        withAnimation(.linear(duration: 0.05)) {
            pinchScale = target
        }
        if event.phase == .ended || event.phase == .cancelled {
            if pinchAccum < -0.25 {
                pinchAccum = 0
                pinchScale = 1
                controller.hide()
            } else {
                pinchAccum = 0
                withAnimation(.spring(duration: 0.3)) {
                    pinchScale = 1
                }
            }
        }
    }
}

/// 窗口后桌面的实时毛玻璃（behindWindow），alpha 值即模糊强度：
/// 0 = 无模糊桌面原样透出，1 = 完全模糊。
private struct DesktopBlurBackground: NSViewRepresentable {
    let intensity: Double

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.alphaValue = intensity
    }
}
