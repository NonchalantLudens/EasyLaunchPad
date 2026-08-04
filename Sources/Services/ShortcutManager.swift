import Carbon.HIToolbox
import Foundation

final class ShortcutManager {
    private static let signature: OSType = 0x4C505441

    private var eventRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private let onPress: () -> Void

    init(keyCode: UInt32, modifiers: UInt32 = 0, onPress: @escaping () -> Void) {
        self.onPress = onPress
        installHandler()
        register(keyCode: keyCode, modifiers: modifiers)
    }

    deinit {
        if let eventRef { UnregisterEventHotKey(eventRef) }
        if let handlerRef { RemoveEventHandler(handlerRef) }
    }

    private func installHandler() {
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let userData = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, userData in
                guard let userData else { return noErr }
                let me = Unmanaged<ShortcutManager>.fromOpaque(userData).takeUnretainedValue()
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if hotKeyID.signature == ShortcutManager.signature {
                    DispatchQueue.main.async { me.onPress() }
                }
                return noErr
            },
            1,
            &spec,
            userData,
            &handlerRef
        )
        assert(status == noErr, "InstallEventHandler failed: \(status)")
    }

    @discardableResult
    func register(keyCode: UInt32, modifiers: UInt32) -> Bool {
        if let eventRef { UnregisterEventHotKey(eventRef); self.eventRef = nil }
        var hotKeyID = EventHotKeyID(signature: Self.signature, id: 1)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &ref
        )
        guard status == noErr else { return false }
        eventRef = ref
        return true
    }
}
