import SwiftUI

/// Kindling's identity: dusk-lavender backdrop (winding-down-for-the-night
/// feel) with a warm ember-coral accent that "glows" as gratitude entries
/// accumulate each night — distinct from every sibling palette.
enum KDTheme {
    static let backdrop = Color(red: 0.933, green: 0.914, blue: 0.949)   // dusk lavender-white
    static let surface = Color.white
    static let surfaceRaised = Color(red: 0.890, green: 0.859, blue: 0.914)
    static let ink = Color(red: 0.196, green: 0.157, blue: 0.212)        // deep plum-ink
    static let inkFaded = Color(red: 0.196, green: 0.157, blue: 0.212).opacity(0.56)
    static let rule = Color.black.opacity(0.08)

    static let lavender = Color(red: 0.518, green: 0.408, blue: 0.600)
    static let lavenderDeep = Color(red: 0.353, green: 0.243, blue: 0.427)
    static let coral = Color(red: 0.933, green: 0.451, blue: 0.376)
    static let coralGlow = Color(red: 0.984, green: 0.573, blue: 0.412)
    static let danger = Color(red: 0.729, green: 0.290, blue: 0.243)

    static let titleFont = Font.system(.title2, design: .serif).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .serif).weight(.semibold)
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
