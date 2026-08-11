import Foundation

/// GitHub Release 信息（版本 + DMG 资产）。
struct ReleaseInfo: Equatable {
    let version: Version
    let tag: String
    let dmgURL: URL
    let sha256: String
}

enum UpdateError: LocalizedError {
    case noRelease
    case noDmgAsset
    case network(Int)
    case checksumMismatch
    case mountFailed
    case appNotFound
    case installFailed(String)

    var errorDescription: String? {
        switch self {
        case .noRelease: return "未找到 Release"
        case .noDmgAsset: return "Release 中未找到 DMG 资产"
        case .network(let code): return "网络请求失败（HTTP \(code)）"
        case .checksumMismatch: return "下载文件校验失败"
        case .mountFailed: return "无法挂载 DMG"
        case .appNotFound: return "安装包中未找到应用"
        case .installFailed(let message): return "安装失败：\(message)"
        }
    }
}

/// 从 GitHub Releases 检查最新版本。
@MainActor
final class UpdateChecker {
    static let repo = "NonchalantLudens/EasyLaunchPad"

    /// 获取最新 release 的版本与 DMG 资产信息。
    func fetchLatest() async throws -> ReleaseInfo {
        let url = URL(string: "https://api.github.com/repos/\(Self.repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("EasyLaunchPad/\(currentVersionString)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UpdateError.network((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tag = json["tag_name"] as? String,
              let version = Version(tag),
              let assets = json["assets"] as? [[String: Any]]
        else {
            throw UpdateError.noRelease
        }
        for asset in assets {
            guard let name = asset["name"] as? String, name.hasSuffix(".dmg"),
                  let urlString = asset["browser_download_url"] as? String,
                  let url = URL(string: urlString),
                  let digest = asset["digest"] as? String
            else { continue }
            let sha = digest.hasPrefix("sha256:") ? String(digest.dropFirst(7)) : digest
            return ReleaseInfo(version: version, tag: tag, dmgURL: url, sha256: sha)
        }
        throw UpdateError.noDmgAsset
    }

    private var currentVersionString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }
}
