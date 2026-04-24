import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist

    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var downloads: DownloadService
    @Environment(\.dismiss) private var dismiss

    @State private var showPlayer = false

    var body: some View {
        ZStack {
            Color.warmBlack.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                    trackList
                }
            }
            .ignoresSafeArea(edges: .top)
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
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showPlayer) {
            PlayerView()
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            if let name = playlist.imageName {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 360)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(0.55), location: 0),
                                .init(color: .clear, location: 0.35),
                                .init(color: .clear, location: 0.55),
                                .init(color: Color.warmBlack, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                LinearGradient(
                    colors: playlist.category.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 360)
            }

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.title)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundColor(.creamWhite)
                    Text(playlist.subtitle)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.creamWhite.opacity(0.75))
                    Text("\(playlist.tracks.count) tracks")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.creamWhite.opacity(0.55))
                }

                Button {
                    handlePlayAll()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Play All")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.warmBlack)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.creamWhite)
                    .clipShape(Capsule())
                }
            }
            .padding(20)
        }
    }

    private var trackList: some View {
        VStack(spacing: 2) {
            ForEach(playlist.tracks) { track in
                TrackRow(
                    track: track,
                    isActive: audio.currentTrack?.id == track.id,
                    isSubscribed: trial.isSubscribed,
                    downloadState: downloadState(for: track),
                    playlistImageName: playlist.imageName,
                    onTap: { handleTrackTap(track) },
                    onDownload: { handleDownload(track) }
                )
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 40)
    }

    private func downloadState(for track: Track) -> DownloadState {
        if downloads.isDownloaded(track)  { return .downloaded }
        if downloads.isDownloading(track) { return .downloading }
        return .none
    }

    private func handlePlayAll() {
        if trial.hasExhaustedTrial {
            appState.showPaywall = true
            return
        }
        let accessibleTracks = trial.isSubscribed
            ? playlist.tracks
            : playlist.tracks.filter { !$0.isPremium }
        guard !accessibleTracks.isEmpty else {
            appState.showPaywall = true
            return
        }
        let localURLs = Dictionary(
            uniqueKeysWithValues: accessibleTracks.compactMap { track -> (UUID, URL)? in
                guard let url = downloads.localURL(for: track) else { return nil }
                return (track.id, url)
            }
        )
        audio.play(playlist: accessibleTracks, startingAt: 0, localURLs: localURLs, imageName: playlist.imageName, totalCount: playlist.tracks.count)
        showPlayer = true
    }

    private func handleTrackTap(_ track: Track) {
        if track.isPremium && !trial.isSubscribed {
            appState.showPaywall = true
            return
        }
        if trial.hasExhaustedTrial {
            appState.showPaywall = true
            return
        }
        let playableTracks = trial.isSubscribed
            ? playlist.tracks
            : playlist.tracks.filter { !$0.isPremium }
        let startIndex = playableTracks.firstIndex(of: track) ?? 0
        let localURLs = Dictionary(
            uniqueKeysWithValues: playableTracks.compactMap { t -> (UUID, URL)? in
                guard let url = downloads.localURL(for: t) else { return nil }
                return (t.id, url)
            }
        )
        audio.play(playlist: playableTracks, startingAt: startIndex, localURLs: localURLs, imageName: playlist.imageName, totalCount: playlist.tracks.count)
        showPlayer = true
    }

    private func handleDownload(_ track: Track) {
        if downloads.isDownloaded(track) {
            downloads.delete(track)
        } else {
            downloads.download(track)
        }
    }
}

// MARK: – Download state

enum DownloadState { case none, downloading, downloaded }

// MARK: – Track row

private struct TrackRow: View {
    let track: Track
    let isActive: Bool
    let isSubscribed: Bool
    let downloadState: DownloadState
    let playlistImageName: String?
    let onTap: () -> Void
    let onDownload: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
            info
            Spacer()
            lockOrDownload
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.mutedCream.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isActive ? Color.charcoal : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var thumbnail: some View {
        ZStack {
            if let name = playlistImageName {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 46, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: track.category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 46, height: 46)
                if !isActive {
                    Image(systemName: track.category.icon)
                        .foregroundColor(.creamWhite.opacity(0.85))
                        .font(.system(size: 16))
                }
            }
            if isActive {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.45))
                    .frame(width: 46, height: 46)
                Image(systemName: "waveform")
                    .foregroundColor(.creamWhite.opacity(0.9))
                    .font(.system(size: 16))
                    .symbolEffect(.variableColor.iterative, isActive: true)
            }
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(track.title)
                .font(.system(size: 15, weight: isActive ? .semibold : .regular, design: .rounded))
                .foregroundColor(isActive ? .mutedGold : .creamWhite)
            HStack(spacing: 6) {
                Text(formatDuration(track.duration))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.mutedCream)
                if downloadState == .downloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.forestGreen)
                }
            }
        }
    }

    @ViewBuilder
    private var lockOrDownload: some View {
        if !isSubscribed {
            // Not subscribed — show lock on premium, nothing on free
            if track.isPremium {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedGold.opacity(0.7))
                    .frame(width: 36, height: 36)
            }
        } else {
            // Subscribed — show download control
            Button(action: onDownload) {
                downloadIcon
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var downloadIcon: some View {
        switch downloadState {
        case .none:
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 20))
                .foregroundColor(.mutedCream.opacity(0.6))
        case .downloading:
            ProgressView()
                .tint(.mutedCream)
                .scaleEffect(0.8)
        case .downloaded:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.forestGreen)
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let hrs  = mins / 60
        return hrs > 0 ? "\(hrs)h loop" : "\(mins)m loop"
    }
}
