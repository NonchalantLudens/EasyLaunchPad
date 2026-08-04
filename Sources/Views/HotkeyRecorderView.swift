import AppKit
import Carbon.HIToolbox
import SwiftUI

struct HotkeyRecorderView: View {
    @EnvironmentObject private var settings: LaunchpadSettings
    @State private var recording = false
    @State private var monitor: Any?

    var body: some View {
        Button {
            beginRecording()
        } label: {
            Text(recording
                ? "按下新快捷键…"
                : HotkeyFormatter.displayText(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers))
                .frame(minWidth: 110)
        }
    }

    private func beginRecording() {
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyCode = UInt32(event.keyCode)
            let modifiers = UInt32(event.modifierFlags.intersection([.command, .control, .option, .shift]).rawValue >> 8)
            let hasModifier = modifiers != 0
            let isFunctionKey = HotkeyFormatter.functionKeys.contains(Int(event.keyCode))
            let isEscape = keyCode == UInt32(kVK_Escape)

            if isEscape && !hasModifier {
                stopRecording()
                return nil
            }
            guard hasModifier || isFunctionKey else {
                return nil
            }
            settings.hotkeyKeyCode = keyCode
            settings.hotkeyModifiers = modifiers
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        recording = false
    }
}
