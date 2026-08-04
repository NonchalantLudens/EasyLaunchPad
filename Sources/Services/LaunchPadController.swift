import AppKit
import Carbon.HIToolbox
import SwiftUI

@MainActor
final class LaunchPadController: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var deleteMode = false

    private var window: LaunchPadWindow?
    private var keyMonitor: Any?
    private var flagsMonitor: Any?
    private var gestureMonitor: Any?
    private var catalog: AppCatalog?
    private var settings: LaunchpadSettings?

    /// The screen the launchpad currently targets (mouse screen at show time).
    private(set) var currentScreen: NSScreen?

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
        currentScreen = target
        let size = settings?.iconSize ?? .medium
        gridLayout = GridLayout.layout(
            for: CGSize(width: target.frame.width, height: target.frame.height - 120),
            itemWidth: size.gridItemWidth,
            itemHeight: size.gridItemHeight
        )

        NSApp.activate(ignoringOtherApps: true)

        if window == nil {
            let window = LaunchPadWindow(
                contentRect: target.frame,
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false,
                screen: target
            )
            window.isOpaque = true
            window.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 1)
            window.hasShadow = false
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            self.window = window
            installMonitors()
        }

        guard let window else { return }
        window.setFrame(target.frame, display: true)
        window.contentView = makeContentView()
        window.alphaValue = 0
        isVisible = true
        window.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.28
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1
        }
    }

    func hide() {
        guard isVisible else { return }
        isVisible = false
        guard let window else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            self?.hideWindow()
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
        window?.contentView = nil
    }
}
