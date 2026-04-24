import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var page = 0

    private let pages: [(icon: String, title: String, body: String)] = [
        (
            "text.bubble.fill",
            "Rewrite the Script",
            "Your body is reading a script God didn't write. \nHis Words replaces it with truth."
        ),
        (
            "brain.head.profile",
            "Backed By Science",
            "Research has proven that the brain rewires for better when scripture is spoken over it."
        ),
        (
            "waveform",
            "Voice Activated",
            "Faith comes by hearing the word of God. Watch your life align with what He says."
        ),
    ]

    var body: some View {
        ZStack {
            Color.warmBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        OnboardingPageView(page: pages[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 420)

                pageIndicator

                Spacer()

                actionButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 52)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Color.mutedGold : Color.charcoal)
                    .frame(width: i == page ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4), value: page)
            }
        }
        .padding(.top, 24)
    }

    private var actionButton: some View {
        Button {
            if page < pages.count - 1 {
                withAnimation { page += 1 }
            } else {
                appState.completeOnboarding()
            }
        } label: {
            Text(page < pages.count - 1 ? "Continue" : "Start Listening")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.warmBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.mutedGold)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct OnboardingPageView: View {
    let page: (icon: String, title: String, body: String)

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.charcoal)
                    .frame(width: 96, height: 96)
                Image(systemName: page.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.mutedGold)
            }

            Text(page.title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundColor(.creamWhite)
                .multilineTextAlignment(.center)

            Text(page.body)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.mutedCream)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 36)
    }
}
