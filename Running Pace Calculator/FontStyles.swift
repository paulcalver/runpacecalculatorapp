import SwiftUI

extension Font {
    
    static var myTitle: Font {
        .system(size: 22, weight: .bold, design: .rounded)
    }
    static var myIcon: Font {
        .system(size: 22, weight: .regular, design: .rounded)
    }

    // Pop Up title + Subsection Title
    static let myHeadline = Font.system(size: 14, weight: .semibold, design: .rounded)
    
    
    static let myCaption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // Unit Input Previews
    static let myInput = Font.system(size: 16, weight: .regular, design: .rounded)
    
    // Unit Input Previews
    static let myInputHeadline = Font.system(size: 18, weight: .regular, design: .rounded)
    
    static let myFootnote = Font.system(size: 14, weight: .regular, design: .rounded)
    static let myFootnoteTitle = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // Splits
    static let mySubheadline = Font.system(size: 14, weight: .regular, design: .rounded)
    
    
}
