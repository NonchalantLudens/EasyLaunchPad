import SwiftUI

struct HiddenAppsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("隐藏的应用")
                .font(.headline)
                .padding(.bottom, 10)
            HiddenAppsList()
        }
        .padding(16)
        .frame(width: 380, height: 300)
    }
}
