import SwiftUI

enum HitCraftFonts {
    // Header (e.g., "CHAT")
    static func header() -> Font {
        return .custom("Poppins-Bold", size: 20)
    }
    
    // Subheader / Section Title
    static func subheader() -> Font {
        return .custom("Poppins-SemiBold", size: 17)
    }
    
    // Body / Chat Messages
    static func body() -> Font {
        return .custom("Poppins-Regular", size: 16)
    }
    
    // Tab Labels / Small Text
    static func caption() -> Font {
        return .custom("Poppins-Medium", size: 14)
    }
    
    // For custom sizes
    static func poppins(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Poppins-Bold", size: size)
        case .semibold:
            return .custom("Poppins-SemiBold", size: size)
        case .medium:
            return .custom("Poppins-Medium", size: size)
        case .light:
            return .custom("Poppins-Light", size: size)
        default:
            return .custom("Poppins-Regular", size: size)
        }
    }
}
