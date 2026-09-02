import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) private var openURL

    @State private var showPlayer = false

    private var exploreTopics: [Topic] {
        Topic.allCases
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        header

                        featuredSection

                        topicSection
                    }
                    .padding(.bottom, audio.currentTrack != nil ? 100 : 32)
                }
            }
            .navigationDestination(for: Topic.self) { topic in
                AmbienceSelectionView(topic: topic)
            }
        }
        // Sits outside the stack so it stays put across pushes.
        .overlay(alignment: .bottom) {
            if audio.currentTrack != nil {
                VStack(spacing: 0) {
                    MiniPlayerView { showPlayer = true }
                    Color.clear.frame(height: 16)
                }
                // Content dissolves into the dark instead of being cut by an edge.
                .background {
                    LinearGradient(
                        stops: [
                            .init(color: .clear,                   location: 0.0),
                            .init(color: .warmBlack.opacity(0.72), location: 0.45),
                            .init(color: .warmBlack,               location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 190)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
                    .allowsHitTesting(false)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: audio.currentTrack != nil)
        .sheet(isPresented: $showPlayer) {
            PlayerView()
        }
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView()
        }
        .onChange(of: trial.hasExhaustedTrial) { _, exhausted in
            if exhausted { appState.showPaywall = true }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("His Words")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundColor(.creamWhite)
                Text("Daily Biblical Affirmations")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.mutedCream)
            }

            Spacer()

            if !trial.isSubscribed {
                Button {
                    appState.showPaywall = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Get Premium")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.warmBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.mutedGold)
                    .clipShape(Capsule())
                }
                .padding(.top, 8)
            } else {
                Menu {
                    Button {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            openURL(url)
                        }
                    } label: {
                        Label("Manage Subscription", systemImage: "creditcard")
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 26))
                        .foregroundColor(.mutedCream)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Featured")

            NavigationLink(value: Topic.featured) {
                FeaturedTopicCard(topic: .featured)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }

    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Explore")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(exploreTopics) { topic in
                    if topic.isAvailable {
                        NavigationLink(value: topic) {
                            TopicCard(topic: topic)
                        }
                        .buttonStyle(.plain)
                    } else {
                        TopicCard(topic: topic)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(.mutedCream)
            .tracking(1.5)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
    }
}

// MARK: – Cards

private struct FeaturedTopicCard: View {
    let topic: Topic

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let name = topic.imageName {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                    .contentShape(Rectangle())
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.charcoal)
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(.creamWhite)
                Text(topic.subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.creamWhite.opacity(0.75))
            }
            .padding(20)
        }
    }
}

private struct TopicCard: View {
    let topic: Topic

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let name = topic.imageName {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color.charcoal, Color.darkCharcoal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: topic.icon)
                        .font(.system(size: 34))
                        .foregroundColor(.creamWhite.opacity(0.22))
                }
            }
            .overlay(
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .topTrailing) {
                if !topic.isAvailable {
                    Text("Coming Soon")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.mutedGold)
                        .tracking(1.1)
                        .textCase(.uppercase)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text(topic.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.creamWhite)
                    .lineLimit(2)
                    .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(topic.isAvailable ? 1 : 0.55)
    }
}
