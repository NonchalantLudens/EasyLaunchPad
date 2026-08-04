import AppKit
import Carbon.HIToolbox
import SwiftUI

extension Notification.Name {
    static let launchPadWillHide = Notification.Name("LaunchPadWillHide")
}

@MainActor
final class LaunchPadController: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var deleteMode = false
    @Published private(set) var enteredFullScreen = false

    private var window: LaunchPadWindow?
    private var keyMonitor: Any?
    private var flagsMonitor: Any?
    private var gestureMonitor: Any?
    private var observers: [NSObjectProtocol] = []
    private var catalog: AppCatalog?
    private var settings: LaunchpadSettings?
    private var pendingTargetScreen: NSScreen?

    /// Set by the content view to handle navigation keys. Return true to consume the event.
    var keyHandler: ((NSEvent) -> Bool)?

    /// Set by the content view to handle trackpad gestures. Return true to consume the event.
    var gestureHandler: ((NSEvent) -> Bool)?

    private(set) var gridLayout = GridLayout(columns: 10, rows: 6)

    func attachCatalog(_ catalog: AppCatalog) {
        self.catalog = catalog
    }

    func attachSettings(_ settings: LaunchpadSettings) {
        self.settings = settings
    }

    func toggle() {
        isVisible ? hide() : show()
    }

    func show() {
        guard !isVisible else { return }
        let target = Self.targetScreen()
        pendingTargetScreen = target
        gridLayout = GridLayout.layout(for: CGSize(width: target.frame.width, height: target.frame.height - 120))

        NSApp.activate(ignoringOtherApps: true)

        if window == nil {
            let window = LaunchPadWindow(
                contentRect: target.frame,
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false,
                screen: target
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.level = .normal
            window.collectionBehavior = [.fullScreenPrimary, .fullScreenAuxiliary, .canJoinAllSpaces]
            self.window = window
            installObservers(for: window)
            installMonitors()
        }

        guard let window else { return }
        window.setFrame(target.frame, display: true)
        window.contentView = makeContentView()
        isVisible = true
        window.makeKeyAndOrderFront(nil)
        window.toggleFullScreen(nil)
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        NotificationCenter.default.post(name: .launchPadWillHide, object: self)
    }

    /// Called by the view after its exit animation finishes.
    func finishHide() {
        guard let window else { return }
        if window.styleMask.contains(.fullScreen) {
            window.toggleFullScreen(nil)
        } else {
            hideWindow()
        }
    }

    /// The screen under the mouse cursor; falls back to the main screen.
    private static func targetScreen() -> NSScreen {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) }
            ?? NSScreen.main
            ?? NSScreen.screens.first!
    }

    private func makeContentView() -> NSHostingView<AnyView> {
        let content = LaunchPadView()
            .environmentObject(self)
        var root = AnyView(content)
        if let catalog {
            root = AnyView(content.environmentObject(catalog))
        }
        if let settings {
            root = AnyView(root.environmentObject(settings))
        }
        return NSHostingView(rootView: root)
    }

    private func installObservers(for window: NSWindow) {
        let enter = NotificationCenter.default.addObserver(
            forName: NSWindow.didEnterFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            guard let self, let target = self.pendingTargetScreen else { return }
            if window.frame != target.frame {
                window.setFrame(target.frame, display: true)
            }
            self.enteredFullScreen = true
        }
        let exit = NotificationCenter.default.addObserver(
            forName: NSWindow.didExitFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.hideWindow()
        }
        observers = [enter, exit]
    }

    private func installMonitors() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.window?.isKeyWindow == true else { return event }
            if let keyHandler, keyHandler(event) {
                return nil
            }
            if event.keyCode == UInt16(kVK_Escape), !event.modifierFlags.contains(.command) {
                self.hide()
                return nil
            }
            return event
        }
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.deleteMode = event.modifierFlags.contains(.option)
            return event
        }
        gestureMonitor = NSEvent.addLocalMonitorForEvents(matching: [.swipe, .magnify, .scrollWheel]) { [weak self] event in
            guard let self, self.window?.isKeyWindow == true else { return event }
            if let gestureHandler, gestureHandler(event) {
                return nil
            }
            return event
        }
    }

    private func hideWindow() {
        window?.orderOut(nil)
        deleteMode = false
        enteredFullScreen = false
        window?.contentView = nil
    }
}
