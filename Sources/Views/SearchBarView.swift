import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
            TextField("搜索应用", text: $text)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .focused(focused)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(width: 300, height: 36)
        .background(.white.opacity(0.15), in: Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            focused.wrappedValue = true
        }
    }
}
