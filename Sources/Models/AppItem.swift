import Foundation

struct AppItem: Identifiable, Equatable {
    let id: String
    let name: String
    let url: URL?

    static func == (lhs: AppItem, rhs: AppItem) -> Bool {
        lhs.id == rhs.id
    }
}
