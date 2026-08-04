import AppKit
import Carbon.HIToolbox
import SwiftUI

struct LaunchPadView: View {
    @EnvironmentObject private var controller: LaunchPadController
    @EnvironmentObject private var catalog: AppCatalog
    @EnvironmentObject private var settings: LaunchpadSettings
    @State private var appeared = false
    @State private var bgAppeared = false
    @State private var selection = GridSelection.zero
    @State private var pages: [[AppItem]] = []
    @State private var searchText = ""
    @State private var pendingActionApp: AppItem?
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
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            Color.black
                .opacity(bgAppeared ? 0.62 : 0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SearchBarView(text: $searchText, focused: $searchFocused)
                    .padding(.top, 56)
                    .opacity(appeared ? 1 : 0)
                Spacer()
                GridPagesView(
                    pages: pages,
                    selection: selection,
                    columns: controller.gridLayout.columns,
                    highlight: searchText.trimmingCharacters(in: .whitespaces),
                    deleteMode: controller.deleteMode,
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
            .scaleEffect(appeared ? 1 * pinchScale : 1.12 * pinchScale)
        }
        .onAppear {
            rebuildPages()
            controller.keyHandler = { event in
                handleKey(event)
            }
            controller.gestureHandler = { event in
                handleGesture(event)
            }
            withAnimation(.easeOut(duration: 0.25)) {
                bgAppeared = true
            }
            withAnimation(.easeOut(duration: 0.35)) {
                appeared = true
            }
        }
        .onDisappear {
            controller.keyHandler = nil
            controller.gestureHandler = nil
        }
        .onReceive(catalog.$apps) { _ in
            rebuildPages()
        }
        .onChange(of: searchText) { _, _ in
            rebuildPages()
        }
        .onReceive(NotificationCenter.default.publisher(for: .launchPadWillHide)) { _ in
            withAnimation(.easeOut(duration: 0.15)) {
                appeared = false
                bgAppeared = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                controller.finishHide()
            }
        }
        .confirmationDialog(
            pendingActionApp.map { "处理「\($0.name)」" } ?? "",
            isPresented: Binding(
                get: { pendingActionApp != nil },
                set: { if !$0 { pendingActionApp = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("从 LaunchPad 隐藏") {
                if let app = pendingActionApp {
                    catalog.hide(app)
                }
            }
            Button("移到废纸篓", role: .destructive) {
                if let app = pendingActionApp {
                    trash(app)
                }
            }
            Button("取消", role: .cancel) {}
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
            // 放行给 TextField：删除、光标移动、中文输入法等
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
