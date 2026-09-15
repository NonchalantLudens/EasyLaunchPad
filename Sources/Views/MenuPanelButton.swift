import SwiftUI

/// 菜单栏面板中的行按钮：悬停高亮（模拟原生菜单项）。
/// 面板所有条目统一使用本组件，保证样式一致。
/// `trailing` 为行尾附加内容（如更新状态），不影响默认样式。
struct MenuPanelButton<Trailing: View>: View {
    let title: String
    let titleColor: Color?
    let action: () -> Void
    var trailing: Trailing

    @State private var isHovered = false

    init(title: String, titleColor: Color? = nil, action: @escaping () -> Void)
    where Trailing == EmptyView {
        self.title = title
        self.titleColor = titleColor
        self.action = action
        self.trailing = EmptyView()
    }

    init(
        title: String,
        titleColor: Color? = nil,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.titleColor = titleColor
        self.action = action
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.body)
                .foregroundStyle(titleColor ?? .primary)
            Spacer(minLength: 0)
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovered ? Color.accentColor : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture(perform: action)
    }
}
