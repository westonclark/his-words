import AVFoundation
import Combine

final class AudioPlayerService: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentPlaylist: [Track] = []
    @Published var currentIndex: Int = 0
    @Published var isLooping: Bool = true
    @Published var sessionSeconds: TimeInterval = 0
    @Published var currentPlaylistImageName: String? = nil
    @Published var currentPlaylistTotalCount: Int = 0

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?
    private var timeObserver: Any?
    private var localURLOverrides: [UUID: URL] = [:]

    init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: [.allowAirPlay, .allowBluetooth]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: – Public API

    func play(playlist: [Track], startingAt index: Int = 0, localURLs: [UUID: URL] = [:], imageName: String? = nil, totalCount: Int = 0) {
        localURLOverrides = localURLs
        currentPlaylist = playlist
        currentIndex = index
        currentPlaylistImageName = imageName
        currentPlaylistTotalCount = totalCount > 0 ? totalCount : playlist.count
        playCurrentTrack()
    }

    // Convenience for single-track play (used by mini-player tap etc.)
    func play(_ track: Track, localURL: URL? = nil) {
        var overrides: [UUID: URL] = [:]
        if let localURL { overrides[track.id] = localURL }
        play(playlist: [track], startingAt: 0, localURLs: overrides)
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying { player?.pause() } else { player?.play() }
        isPlaying.toggle()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func next() {
        let nextIndex = currentIndex + 1
        if nextIndex < currentPlaylist.count {
            currentIndex = nextIndex
            playCurrentTrack()
        } else if isLooping {
            currentIndex = 0
            playCurrentTrack()
        } else {
            stop()
        }
    }

    func previous() {
        let prevIndex = currentIndex - 1
        if prevIndex >= 0 {
            currentIndex = prevIndex
            playCurrentTrack()
        } else if isLooping {
            currentIndex = currentPlaylist.count - 1
            playCurrentTrack()
        }
    }

    func toggleLoop() {
        isLooping.toggle()
    }

    func stop() {
        teardown()
        currentPlaylist = []
        currentIndex = 0
        currentPlaylistTotalCount = 0
        currentPlaylistImageName = nil
    }

    func resetSessionTime() {
        sessionSeconds = 0
    }

    // MARK: – Private

    private func playCurrentTrack() {
        guard currentIndex < currentPlaylist.count else { return }
        let track = currentPlaylist[currentIndex]
        let url = localURLOverrides[track.id] ?? URL(string: track.streamURL)
        guard let url else { return }

        teardown()
        currentTrack = track

        let item = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: item)
        player = avPlayer

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.next()
        }

        timeObserver = avPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] _ in
            self?.sessionSeconds += 1
        }

        avPlayer.play()
        isPlaying = true
    }

    private func teardown() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }
        player?.pause()
        player = nil
        isPlaying = false
        currentTrack = nil
    }
}
