import Foundation

/// 语义化版本（MAJOR.MINOR.PATCH），用于更新比较。
struct Version: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// 解析 "0.1.0" / "v0.1.0"，容忍缺省 patch。
    init?(_ string: String) {
        var cleaned = string.trimmingCharacters(in: .whitespaces)
        if cleaned.hasPrefix("v") {
            cleaned.removeFirst()
        }
        let parts = cleaned.split(separator: ".").prefix(3).map { Int($0) }
        guard let major = parts.first, let major, parts.count >= 1, let minor = parts.count > 1 ? parts[1] : 0 else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = parts.count > 2 ? (parts[2] ?? 0) : 0
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    var description: String {
        "\(major).\(minor).\(patch)"
    }
}
