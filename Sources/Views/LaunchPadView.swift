import AppKit
import Carbon.HIToolbox
import SwiftUI

struct LaunchPadView: View {
    @EnvironmentObject private var controller: LaunchPadController
    @EnvironmentObject private var catalog: AppCatalog
    @EnvironmentObject private var settings: LaunchpadSettings
    @State private var appeared = false
    @State private var jigglePhase: Double = 0
    @State private var jiggleTimer: Timer?
    @State private var selection = GridSelection.zero
    @State private var pages: [[AppItem]] = []
    @State private var searchText = ""
    @State private var pendingActionApp: AppItem?
    @State private var wallpaper: NSImage?
    @State private var pinchScale: CGFloat = 1
    @State private var pinchAccum: CGFloat = 0
    @State private var swipeDelta: CGFloat = 0
    @FocusState private var searchFocused: Bool

    private var filteredApps: [AppItem] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return catalog.apps }
        return catalog.apps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
            if let wallpaper {
                Image(nsImage: wallpaper)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
            LinearGradient(
                colors: [.black.opacity(0.4), .black.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                SearchBarView(text: $searchText, focused: $searchFocused)
                    .padding(.top, 56)
                Spacer()
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
                    onSelect: open,
                    onBadge: { pendingActionApp = $0 }
                )
                .frame(maxHeight: .infinity)
                Spacer()
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    PageDotsView(
                        pageCount: pages.count,
                        currentPage: selection.pageIndex
                    )
                    .transition(.opacity)
                }
                Spacer()
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
            let screen = controller.currentScreen ?? NSScreen.main
            if let screen {
                WallpaperStore.shared.load(for: screen) { image in
                    wallpaper = image
                }
            }
            withAnimation(.easeOut(duration: 0.3)) {
                appeared = true
            }
        }
        .onDisappear {
            controller.keyHandler = nil
            controller.gestureHandler = nil
            jiggleTimer?.invalidate()
            jiggleTimer = nil
        }
        .onChange(of: controller.deleteMode) { _, enabled in
            jiggleTimer?.invalidate()
            jiggleTimer = nil
            jigglePhase = 0
            if enabled {
                jiggleTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
                    jigglePhase += 0.45
                }
            }
        }
        .onReceive(catalog.$apps) { _ in
            rebuildPages()
        }
        .onChange(of: searchText) { _, _ in
            rebuildPages()
        }
        .alert(
            "处理应用",
            isPresented: Binding(
                get: { pendingActionApp != nil },
                set: { if !$0 { pendingActionApp = nil } }
            ),
            presenting: pendingActionApp
        ) { app in
            Button("从 LaunchPad 隐藏") {
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

    private func rebuildPages() {
        pages = controller.gridLayout.pages(filteredApps)
        selection = GridNavigation.clamp(selection, pageCounts: pages.map(\.count))
    }

    private func open(_ app: AppItem) {
        if let url = app.url {
            NSWorkspace.shared.open(url)
        }
        controller.hide()
    }

    private func openSelected() {
        guard !pages.isEmpty else { return }
        let page = pages[selection.pageIndex]
        guard page.indices.contains(selection.itemIndex) else { return }
        open(page[selection.itemIndex])
    }

    private func move(_ direction: GridDirection) {
        selection = GridNavigation.move(
            direction,
            from: selection,
            pageCounts: pages.map(\.count),
            columns: controller.gridLayout.columns
        )
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
                move(event.deltaX < 0 ? .right : .left)
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
                swipeDelta += event.scrollingDeltaX
            }
            if event.phase.contains(.ended) {
                if abs(swipeDelta) > 50 {
                    move(swipeDelta < 0 ? .right : .left)
                }
                swipeDelta = 0
                return true
            }
            if event.phase == [] {
                if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY), abs(event.scrollingDeltaX) > 10 {
                    move(event.scrollingDeltaX < 0 ? .right : .left)
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
