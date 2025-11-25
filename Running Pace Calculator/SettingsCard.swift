import SwiftUI

struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}
