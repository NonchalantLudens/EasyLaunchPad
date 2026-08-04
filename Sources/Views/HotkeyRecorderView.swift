import AppKit
import Carbon.HIToolbox
import SwiftUI

struct HotkeyRecorderView: View {
    @EnvironmentObject private var settings: LaunchpadSettings
    @State private var recording = false
    @State private var monitor: Any?
    @State private var hint: String?
    var onRecordingChange: (Bool) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Button {
                beginRecording()
            } label: {
                Text(recording
                    ? "按下新快捷键…"
                    : HotkeyFormatter.displayText(keyCode: settings.hotkeyKeyCode, modifiers: settings.hotkeyModifiers))
                    .frame(minWidth: 110)
            }
            if let hint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func beginRecording() {
        recording = true
        hint = nil
        onRecordingChange(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyCode = UInt32(event.keyCode)
            let modifiers = Self.carbonModifiers(for: event.modifierFlags)
            let isEscape = keyCode == UInt32(kVK_Escape)

            if isEscape && modifiers == 0 {
                stopRecording()
                return nil
            }
            guard modifiers != 0 || HotkeyFormatter.functionKeys.contains(Int(event.keyCode)) else {
                showInvalidHint()
                return nil
            }
            settings.hotkeyKeyCode = keyCode
            settings.hotkeyModifiers = modifiers
            stopRecording()
            return nil
        }
    }

    private static func carbonModifiers(for flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        if flags.contains(.option) { mods |= UInt32(optionKey) }
        if flags.contains(.shift) { mods |= UInt32(shiftKey) }
        return mods
    }

    private func showInvalidHint() {
        hint = "需要 ⌘⌥⌃⇧ 或功能键"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !recording {
                hint = nil
            }
        }
    }

    private func stopRecording() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        recording = false
        hint = nil
        onRecordingChange(false)
    }
}
