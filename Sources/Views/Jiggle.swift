import AppKit
import SwiftUI

struct Jiggle: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            PhaseAnimator([-1.0, 1.0]) { phase in
                content
                    .rotationEffect(.degrees(phase * 2.2))
                    .offset(x: phase * 1.2)
            } animation: { _ in
                .easeInOut(duration: 0.11)
            }
        } else {
            content
        }
    }
}

extension View {
    func jiggle(_ active: Bool) -> some View {
        modifier(Jiggle(active: active))
    }
}
