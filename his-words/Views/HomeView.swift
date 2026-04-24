import SwiftUI

struct HomeView: View {
    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) private var openURL

    @State private var selectedPlaylist: Playlist?
    @State private var showPlayer = false

    private let playlists = Playlist.catalog

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.warmBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        header

                        featuredSection

                        categorySection
                    }
                    .padding(.bottom, audio.currentTrack != nil ? 100 : 32)
                }

                if audio.currentTrack != nil {
                    VStack(spacing: 0) {
                        MiniPlayerView { showPlayer = true }
                        Color.clear.frame(height: 16)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(for: Playlist.self) { playlist in
                PlaylistDetailView(playlist: playlist)
            }
        }
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

            NavigationLink(value: Playlist.featured) {
                FeaturedCard(playlist: Playlist.featured)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Explore")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(playlists) { playlist in
                    NavigationLink(value: playlist) {
                        CategoryCard(playlist: playlist)
                    }
                    .buttonStyle(.plain)
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

private struct FeaturedCard: View {
    let playlist: Playlist

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let name = playlist.imageName {
              Image(name)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: UIScreen.main.bounds.width - 40, height: 200) // Explicit width/height
                  .contentShape(Rectangle()) // Explicitly defines the hit testing area
                  .clipped()
                  .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: playlist.category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.title)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(.creamWhite)
                Text(playlist.subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.creamWhite.opacity(0.75))
            }
            .padding(20)
        }
    }
}

private struct CategoryCard: View {
    let playlist: Playlist

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let name = playlist.imageName {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: playlist.category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: playlist.category.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.15))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(14)
                }
            }
            .overlay(
                LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .bottomLeading) {
                Text(playlist.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.creamWhite)
                    .lineLimit(2)
                    .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct PremiumBadge: View {
    var body: some View {
        Text("PREMIUM")
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundColor(.mutedGold)
            .tracking(1.2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.35))
            .clipShape(Capsule())
    }
}
