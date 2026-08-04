import AppKit
import Carbon.HIToolbox
import SwiftUI

extension Notification.Name {
    static let launchPadWillHide = Notification.Name("LaunchPadWillHide")
}

@MainActor
final class LaunchPadController: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var enteredFullScreen = false
    @Published private(set) var deleteMode = false

    private var window: NSWindow?
    private var keyMonitor: Any?
    private var flagsMonitor: Any?
    private var observers: [NSObjectProtocol] = []
    private var catalog: AppCatalog?

    /// Set by the content view to handle navigation keys. Return true to consume the event.
    var keyHandler: ((NSEvent) -> Bool)?

    private(set) var gridLayout = GridLayout(columns: 10, rows: 6)

    func attachCatalog(_ catalog: AppCatalog) {
        self.catalog = catalog
    }

    func toggle() {
        isVisible ? hide() : show()
    }

    func show() {
        guard !isVisible else { return }
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }

        isVisible = true
        NSApp.activate(ignoringOtherApps: true)
        gridLayout = GridLayout.layout(for: CGSize(width: screen.frame.width, height: screen.frame.height - 120))

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .normal
        window.collectionBehavior = [.fullScreenPrimary, .fullScreenAuxiliary, .canJoinAllSpaces]

        let content = LaunchPadView()
            .environmentObject(self)
        if let catalog {
            window.contentView = NSHostingView(
                rootView: content.environmentObject(catalog)
            )
        } else {
            window.contentView = NSHostingView(rootView: content)
        }

        self.window = window
        installObservers(for: window)
        installKeyMonitor()
        window.makeKeyAndOrderFront(nil)
        window.toggleFullScreen(nil)
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        enteredFullScreen = false
        NotificationCenter.default.post(name: .launchPadWillHide, object: self)
    }

    /// Called by the view after its exit animation finishes.
    func finishHide() {
        guard let window else { return }
        if window.styleMask.contains(.fullScreen) {
            window.toggleFullScreen(nil)
        } else {
            closeWindow()
        }
    }

    private func installObservers(for window: NSWindow) {
        let enter = NotificationCenter.default.addObserver(
            forName: NSWindow.didEnterFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.enteredFullScreen = true
        }
        let exit = NotificationCenter.default.addObserver(
            forName: NSWindow.didExitFullScreenNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.closeWindow()
        }
        observers = [enter, exit]
    }

    private func installKeyMonitor() {
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
    }

    private func closeWindow() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers = []
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
        if let flagsMonitor {
            NSEvent.removeMonitor(flagsMonitor)
            self.flagsMonitor = nil
        }
        deleteMode = false
        window?.close()
        window = nil
    }
}
