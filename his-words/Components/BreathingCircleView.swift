import SwiftUI

struct BreathingCircleView: View {
    let gradient: [Color]

    @State private var expanded = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gradient[0].opacity(0.35 - Double(i) * 0.10),
                                gradient[1].opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: expanded ? 160 + Double(i) * 40 : 120 + Double(i) * 40
                        )
                    )
                    .scaleEffect(expanded ? 1.0 + Double(i) * 0.12 : 0.82 + Double(i) * 0.08)
                    .animation(
                        .easeInOut(duration: 4.5).repeatForever(autoreverses: true).delay(Double(i) * 0.6),
                        value: expanded
                    )
            }

            Circle()
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 120, height: 120)
                .scaleEffect(expanded ? 1.08 : 0.92)
                .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: expanded)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        .scaleEffect(expanded ? 1.08 : 0.92)
                        .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: expanded)
                )
        }
        .frame(width: 300, height: 300)
        .onAppear { expanded = true }
    }
}
