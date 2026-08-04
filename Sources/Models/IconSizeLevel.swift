import CoreGraphics

/// 图标大小分级（设置页可切换，4 级默认）。
enum IconSizeLevel: Int, CaseIterable, Identifiable {
    case small = 0
    case medium = 1
    case large = 2
    case extraLarge = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .small: return "小"
        case .medium: return "中"
        case .large: return "大"
        case .extraLarge: return "特大"
        }
    }

    var iconPoint: CGFloat {
        switch self {
        case .small: return 72
        case .medium: return 96
        case .large: return 120
        case .extraLarge: return 144
        }
    }

    var ringPoint: CGFloat { iconPoint + 4 }
    var iconCornerRadius: CGFloat { iconPoint * 0.25 }

    var tileWidth: CGFloat {
        switch self {
        case .small: return 104
        case .medium: return 140
        case .large: return 174
        case .extraLarge: return 208
        }
    }

    var tileHeight: CGFloat {
        switch self {
        case .small: return 116
        case .medium: return 150
        case .large: return 184
        case .extraLarge: return 218
        }
    }

    var nameWidth: CGFloat {
        switch self {
        case .small: return 100
        case .medium: return 132
        case .large: return 160
        case .extraLarge: return 190
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 32
        case .large: return 36
        case .extraLarge: return 40
        }
    }

    var gridItemWidth: CGFloat { tileWidth + spacing + 4 }
    var gridItemHeight: CGFloat { tileHeight + spacing + 4 }

    /// 删除徽标相对图块右上角的偏移（对齐图标右上角）。
    var badgeTrailing: CGFloat { max(0, (tileWidth - iconPoint) / 2 - 6) }
    var badgeTop: CGFloat { max(0, (tileHeight - iconPoint - 42) / 2 - 6) }
}
