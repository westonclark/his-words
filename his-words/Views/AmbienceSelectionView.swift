import SwiftUI

/// Step two of the flow: pick the ambient bed, then playback starts immediately
/// and runs straight through the topic from the first track.
///
/// Presented as a list rather than a card grid so it reads as a setting applied
/// to the topic, not as a second content picker competing with Explore.
struct AmbienceSelectionView: View {
    let topic: Topic

    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showPlayer = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    heading
                    ambienceList
                }
                .padding(.bottom, audio.currentTrack != nil ? 110 : 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.creamWhite)
                }
            }
        }
        .fullScreenCover(isPresented: $showPlayer) {
            PlayerView()
        }
    }

    // MARK: – Heading

    private var heading: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(topic.title)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.creamWhite)

            nowPlayingSummary
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    /// Confirms what is about to play, so the ambience choice below can't be
    /// mistaken for choosing the content itself.
    private var nowPlayingSummary: some View {
        HStack(spacing: 6) {
            Image(systemName: topic.icon)
                .font(.system(size: 11))
            Text(summaryText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .foregroundColor(.mutedGold)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.charcoal)
        .clipShape(Capsule())
    }

    /// What this topic amounts to: a set of tracks, or a single continuous loop.
    /// Read off the default context, since the count is the same for every
    /// ambience and only the male "You Are" set is shorter.
    private var summaryText: String {
        let tracks = Catalog.tracks(for: PlaybackContext(topic: topic, ambience: .oceanWaves))
        if tracks.count == 1, tracks[0].isLoop { return "Endless Loop" }
        return tracks.count == 1 ? "1 track" : "\(tracks.count) tracks"
    }

    // MARK: – List

    private var ambienceList: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CHOOSE YOUR AMBIENCE")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(.mutedCream)
                Text("Pick the sound you'd like to rest in.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.mutedCream.opacity(0.75))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            ForEach(Ambience.allCases) { ambience in
                Button {
                    startPlayback(ambience)
                } label: {
                    AmbienceRow(ambience: ambience)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func startPlayback(_ ambience: Ambience) {
        guard !trial.hasExhaustedTrial else {
            appState.showPaywall = true
            return
        }
        audio.start(PlaybackContext(topic: topic, ambience: ambience))
        showPlayer = true
    }
}

// MARK: – Row

private struct AmbienceRow: View {
    let ambience: Ambience

    var body: some View {
        HStack(spacing: 14) {
            Image(ambience.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(ambience.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.creamWhite)
                Text(ambience.soundDescription)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.mutedCream)
            }

            Spacer(minLength: 8)

            Image(systemName: "play.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.mutedGold.opacity(0.85))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
