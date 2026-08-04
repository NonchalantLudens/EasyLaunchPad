import Foundation

enum TrashService {
    @discardableResult
    static func trash(_ url: URL) -> Bool {
        var resultURL: NSURL?
        do {
            try FileManager.default.trashItem(at: url, resultingItemURL: &resultURL)
            return true
        } catch {
            return false
        }
    }
}
