import AppKit
import SwiftUI

/// 菜单栏状态项与下拉面板控制器。
/// 替代 MenuBarExtra(.window)：面板不抢焦点、点击外部自动收起、
/// 条目点击后可主动收起，交互由本类统一管理。
@MainActor
final class StatusBarPanelController: NSObject, ObservableObject {
    static let shared = StatusBarPanelController()

    @Published private(set) var isPanelVisible = false

    /// 上次切换时间：状态按钮的按下/抬起可能各触发一次 action，去抖防止关了又弹。
    private var lastToggleAt: CFAbsoluteTime = 0

    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var outsideClickMonitor: Any?
    private var statusClickMonitor: Any?

    /// 应用启动时安装状态项；content 为面板的 SwiftUI 根视图。
    func install(content: NSView) {
        guard statusItem == nil else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: "square.grid.3x3",
            accessibilityDescription: "EasyLaunchPad"
        )
        statusItem = item
        // 不用按钮的 target/action：其按下/抬起触发时机不可控（一次点击可能
        // 触发两次导致"关了又弹"）。改为本地事件监视器精确判定点击落点，
        // 每次点击恰好切换一次
        statusClickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self,
                  let button = self.statusItem?.button,
                  let buttonWindow = button.window,
                  event.window === buttonWindow else { return event }
            self.togglePanel()
            return nil
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 244, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .statusBar
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.animationBehavior = .utilityWindow
        panel.contentView = content
        self.panel = panel
    }

    private func togglePanel() {
        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastToggleAt > 0.2 else { return }
        lastToggleAt = now
        // 以窗口实际可见性为准，不依赖簿记状态
        if panel?.isVisible == true {
            hide()
        } else {
            show()
        }
    }

    func show() {
        guard let panel, let button = statusItem?.button else { return }
        sizePanelToFit()
        positionPanel(panel, belowButton: button)
        installOutsideClickMonitor()
        panel.orderFront(nil)
        isPanelVisible = true
    }

    func hide() {
        guard let panel else { return }
        removeOutsideClickMonitor()
        panel.orderOut(nil)
        isPanelVisible = false
    }

    /// 面板尺寸跟随内容（内联更新状态会改变高度）。
    private func sizePanelToFit() {
        guard let panel, let content = panel.contentView else { return }
        let fitting = content.fittingSize
        if fitting.width > 0, fitting.height > 0 {
            panel.setContentSize(fitting)
        }
    }

    /// 面板顶部对齐状态项图标下方，水平与图标中心对齐并收敛到屏幕内。
    private func positionPanel(_ panel: NSPanel, belowButton button: NSStatusBarButton) {
        guard let buttonWindow = button.window else { return }
        let buttonFrame = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        guard let screen = buttonWindow.screen ?? NSScreen.main else { return }
        let visible = screen.visibleFrame
        var origin = CGPoint(
            x: buttonFrame.midX - panel.frame.width / 2,
            y: buttonFrame.minY - panel.frame.height - 5
        )
        origin.x = min(max(origin.x, visible.minX + 8), visible.maxX - panel.frame.width - 8)
        origin.y = max(origin.y, visible.minY + 8)
        panel.setFrameOrigin(origin)
    }

    /// 面板为非激活窗口，面板外的点击会投递给其他应用；
    /// 用全局监听在用户点击别处时自动收起面板。
    private func installOutsideClickMonitor() {
        guard outsideClickMonitor == nil else { return }
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.hide()
            }
        }
    }

    private func removeOutsideClickMonitor() {
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
            self.outsideClickMonitor = nil
        }
    }
}
