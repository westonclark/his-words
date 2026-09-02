import SwiftUI

extension Color {
    static let warmBlack    = Color(red: 0.067, green: 0.067, blue: 0.063)  // #111110
    static let darkCharcoal = Color(red: 0.118, green: 0.118, blue: 0.110)  // #1e1e1c
    static let charcoal     = Color(red: 0.165, green: 0.165, blue: 0.157)  // #2a2a28
    static let creamWhite   = Color(red: 0.941, green: 0.929, blue: 0.902)  // #f0ede6
    static let mutedCream   = Color(red: 0.522, green: 0.498, blue: 0.471)  // #857f78
    static let mutedGold    = Color(red: 0.75,  green: 0.62,  blue: 0.35)   // unchanged
    static let forestGreen  = Color(red: 0.12,  green: 0.42,  blue: 0.28)   // unchanged
}

/// The app's ground. Warm near-black with a faint lift at the top and a
/// deepening toward the bottom, so the screen reads as a dim room rather than
/// a flat void — without competing with the photography it sits behind.
struct AppBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.086, green: 0.084, blue: 0.078), location: 0.0),
                .init(color: .warmBlack,                                   location: 0.42),
                .init(color: Color(red: 0.051, green: 0.050, blue: 0.047), location: 1.0),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
