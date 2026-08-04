import AppKit
import Carbon.HIToolbox
import SwiftUI

struct LaunchPadView: View {
    @EnvironmentObject private var controller: LaunchPadController
    @EnvironmentObject private var catalog: AppCatalog
    @State private var appeared = false
    @State private var selection = GridSelection.zero
    @State private var pages: [[AppItem]] = []
    @State private var searchText = ""
    @State private var pendingActionApp: AppItem?
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
            .scaleEffect(appeared ? 1 : 1.12)
        }
        .onAppear {
            rebuildPages()
            controller.keyHandler = { event in
                handleKey(event)
            }
        }
        .onDisappear {
            controller.keyHandler = nil
        }
        .onReceive(catalog.$apps) { _ in
            rebuildPages()
        }
        .onChange(of: searchText) { _, _ in
            rebuildPages()
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
                searchFocused = false
            } else {
                controller.hide()
            }
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
}
