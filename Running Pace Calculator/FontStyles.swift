import SwiftUI

extension Font {
    
    // Main Titles
    static var myTitle: Font {
        // Use custom Space Grotesk Bold if available; otherwise fall back to system rounded bold
        if UIFont(name: "SpaceGrotesk-Bold", size: 28) != nil {
            return .custom("SpaceGrotesk-Bold", size: 28)
        } else {
            return .system(size: 22, weight: .bold, design: .rounded)
        }
    }

    // Body Text
    static var myHeadline: Font {
        if UIFont(name: "SpaceGrotesk-Bold", size: 16) != nil {
            return .custom("SpaceGrotesk-Bold", size: 16)
        } else {
            return .system(size: 14, weight: .semibold, design: .rounded)
        }
    }
    static var myCaption: Font {
        if UIFont(name: "SpaceGrotesk-Regular", size: 16) != nil {
            return .custom("SpaceGrotesk-Regular", size: 16)
        } else {
            return .system(size: 14, weight: .regular, design: .rounded)
        }
    }

    // Unit Input Previews
    static var myInput: Font {
        if UIFont(name: "SpaceGrotesk-Regular", size: 18) != nil {
            return .custom("SpaceGrotesk-Regular", size: 18)
        } else {
            return .system(size: 16, weight: .regular, design: .rounded)
        }
    }
    
    // Reset Button
    static var myInputBold: Font {
        if UIFont(name: "SpaceGrotesk-Bold", size: 18) != nil {
            return .custom("SpaceGrotesk-Bold", size: 18)
        } else {
            return .system(size: 16, weight: .regular, design: .rounded)
        }
    }
    
    // Unit Input Description Text
    static let myInputHeadline = Font.system(size: 18, weight: .bold, design: .rounded)
    
    // Icon size
    static var myIcon: Font {
        .system(size: 22, weight: .regular, design: .rounded)
    }

}
