import SwiftUI
import UIKit

extension Color {
    /// App-wide background color for SwiftUI. Uses Color asset "AppBackground" if available,
    /// otherwise falls back to the system background.
    static var appBackgroundColor: Color {
        if let uiColor = UIColor(named: "AppBackground") {
            return Color(uiColor)
        } else {
            return Color(.systemBackground)
        }
    }
}

extension UIColor {
    /// UIKit version of the app-wide background color.
    /// Uses the "AppBackground" asset if available, otherwise falls back to systemBackground.
    static var appBackgroundColor: UIColor {
        return UIColor(named: "AppBackground") ?? .systemBackground
    }
}
