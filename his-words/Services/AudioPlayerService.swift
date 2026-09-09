import AVFoundation
import Combine
import MediaPlayer
import UIKit

/// Playback runs on a single long-lived `AVQueuePlayer`. The whole remaining
/// playlist is enqueued up front so AVFoundation buffers the next track while
/// the current one is still playing and advances without a gap — tearing down
/// a player per track (the old approach) meant a fresh network fetch and an
/// audible stop/start at every boundary.
final class AudioPlayerService: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentPlaylist: [Track] = []
    @Published var currentIndex: Int = 0
    @Published var isLooping: Bool = true
    @Published var sessionSeconds: TimeInterval = 0
    @Published var currentPlaylistImageName: String? = nil
    @Published var currentPlaylistTotalCount: Int = 0

    /// Position and length of the current track, for the scrubber.
    @Published var playbackTime: TimeInterval = 0
    @Published var playbackDuration: TimeInterval = 0

    /// What is playing and how — drives the voice / person toggles in the player.
    @Published private(set) var context: PlaybackContext?

    /// Supplies an on-disk file for a track when one has been downloaded.
    /// Injected at launch so the service can rebuild playlists on its own.
    var localURLProvider: ((Track) -> URL?)?

    private let player = AVQueuePlayer()
    private var timeObserver: Any?
    private var currentItemObservation: NSKeyValueObservation?
    private var loopObserver: NSObjectProtocol?
    private var localURLOverrides: [UUID: URL] = [:]

    /// Which playlist index each queued item represents, so an advance to the
    /// next item can be reflected in the UI without re-deriving it from URLs.
    private var indexByItem: [ObjectIdentifier: Int] = [:]

    /// Set while the user drags the scrubber, so the time observer doesn't
    /// yank the thumb back to the playhead mid-gesture.
    private var isScrubbing = false

    /// Set while the queue is being rebuilt, so the resulting `currentItem`
    /// changes aren't mistaken for the player advancing on its own.
    private var isRebuilding = false

    init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: [.allowAirPlay, .allowBluetoothHFP]
        )
        try? AVAudioSession.sharedInstance().setActive(true)

        player.actionAtItemEnd = .advance
        observeCurrentItem()
        observeTime()
        configureRemoteCommands()
    }

    deinit {
        if let timeObserver { player.removeTimeObserver(timeObserver) }
    }

    // MARK: – Public API

    /// Starts a topic + ambience from the top and plays straight through.
    func start(_ context: PlaybackContext) {
        self.context = context
        loadContextPlaylist(startingAt: 0)
    }

    /// Swaps the narrator, restarting the current track in the new voice.
    func setVoice(_ voice: VoiceOption) {
        guard var context, context.voice != voice else { return }
        context.voice = voice
        self.context = context
        PlaybackPreferences.voice = voice
        loadContextPlaylist(startingAt: currentIndex)
    }

    /// Swaps 1st / 2nd person. The recordings don't line up, so playback restarts.
    func setPerson(_ person: PersonOption) {
        guard var context, context.person != person else { return }
        context.person = person
        self.context = context
        PlaybackPreferences.person = person
        loadContextPlaylist(startingAt: 0)
    }

    func play(playlist: [Track], startingAt index: Int = 0, localURLs: [UUID: URL] = [:], imageName: String? = nil, totalCount: Int = 0) {
        localURLOverrides = localURLs
        currentPlaylist = playlist
        currentPlaylistImageName = imageName
        currentPlaylistTotalCount = totalCount > 0 ? totalCount : playlist.count
        rebuildQueue(startingAt: index)
    }

    // Convenience for single-track play (used by mini-player tap etc.)
    func play(_ track: Track, localURL: URL? = nil) {
        var overrides: [UUID: URL] = [:]
        if let localURL { overrides[track.id] = localURL }
        play(playlist: [track], startingAt: 0, localURLs: overrides)
    }

    func togglePlayPause() {
        guard player.currentItem != nil else {
            // Playback ran off the end of a non-looping playlist: the queue is
            // empty, so pressing play again starts over from the top.
            if !currentPlaylist.isEmpty { rebuildQueue(startingAt: 0) }
            return
        }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    func pause() {
        player.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }

    func toggleLoop() {
        isLooping.toggle()
    }

    /// Skipping forward is the one jump the queue already holds buffered, so it
    /// advances rather than rebuilding.
    func next() {
        guard !currentPlaylist.isEmpty else { return }
        if currentIndex + 1 < currentPlaylist.count {
            player.advanceToNextItem()
        } else if isLooping {
            rebuildQueue(startingAt: 0)
        } else {
            pause()
        }
    }

    func previous() {
        guard !currentPlaylist.isEmpty else { return }
        if currentIndex - 1 >= 0 {
            rebuildQueue(startingAt: currentIndex - 1)
        } else if isLooping {
            rebuildQueue(startingAt: currentPlaylist.count - 1)
        }
    }

    func stop() {
        clearQueue()
        currentPlaylist = []
        currentIndex = 0
        currentPlaylistTotalCount = 0
        currentPlaylistImageName = nil
        currentTrack = nil
        context = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    /// Moves the thumb without seeking — called continuously during a drag.
    func beginScrub(to seconds: TimeInterval) {
        isScrubbing = true
        playbackTime = seconds
    }

    /// Commits the drag: seeks the player and resumes following the playhead.
    func endScrub(to seconds: TimeInterval) {
        playbackTime = seconds
        player.seek(
            to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        ) { [weak self] _ in
            self?.isScrubbing = false
            self?.updateNowPlayingInfo()
        }
    }

    func resetSessionTime() {
        sessionSeconds = 0
    }

    // MARK: – Queue

    private func loadContextPlaylist(startingAt index: Int) {
        guard let context else { return }
        let tracks = Catalog.tracks(for: context)
        guard !tracks.isEmpty else { return }

        let overrides = Dictionary(
            uniqueKeysWithValues: tracks.compactMap { track -> (UUID, URL)? in
                guard let url = localURLProvider?(track) else { return nil }
                return (track.id, url)
            }
        )
        play(
            playlist: tracks,
            startingAt: min(max(index, 0), tracks.count - 1),
            localURLs: overrides,
            imageName: context.imageName
        )
    }

    /// Enqueues everything from `index` to the end of the playlist. Only jumps
    /// need this; ordinary track-to-track advances are handled by the queue.
    private func rebuildQueue(startingAt index: Int) {
        guard !currentPlaylist.isEmpty else { return }
        let start = min(max(index, 0), currentPlaylist.count - 1)

        isRebuilding = true
        clearQueue()

        for offset in start..<currentPlaylist.count {
            let track = currentPlaylist[offset]
            let url = localURLOverrides[track.id] ?? URL(string: track.streamURL)
            guard let url else { continue }
            let item = AVPlayerItem(url: url)
            indexByItem[ObjectIdentifier(item)] = offset
            player.insert(item, after: nil)
        }
        isRebuilding = false

        configureLooping(for: currentPlaylist[start])

        currentIndex = start
        currentTrack = currentPlaylist[start]
        playbackTime = 0
        playbackDuration = 0

        player.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    private func clearQueue() {
        if let loopObserver {
            NotificationCenter.default.removeObserver(loopObserver)
            self.loopObserver = nil
        }
        player.actionAtItemEnd = .advance
        player.pause()
        player.removeAllItems()
        indexByItem.removeAll()
        isPlaying = false
        isScrubbing = false
        playbackTime = 0
        playbackDuration = 0
    }

    /// An endless-loop track rewinds in place at the end rather than letting the
    /// queue drain, which would re-fetch the file and put a gap in the loop.
    private func configureLooping(for track: Track) {
        guard track.isLoop, currentPlaylist.count == 1 else { return }
        player.actionAtItemEnd = .none
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            self.player.play()
        }
    }

    // MARK: – Observation

    /// The queue advancing on its own is the only place `currentIndex` moves
    /// without an explicit rebuild, so the UI follows the player rather than
    /// the other way round.
    private func observeCurrentItem() {
        currentItemObservation = player.observe(\.currentItem, options: [.new]) { [weak self] _, _ in
            guard let self, !self.isRebuilding else { return }
            DispatchQueue.main.async { self.currentItemChanged() }
        }
    }

    private func currentItemChanged() {
        guard let item = player.currentItem else {
            // Queue drained: loop back to the top, or hold at the end of the
            // last track rather than clearing it (which would blank the player).
            if isLooping, !currentPlaylist.isEmpty {
                rebuildQueue(startingAt: 0)
            } else {
                pause()
            }
            return
        }
        guard let index = indexByItem[ObjectIdentifier(item)] else { return }
        currentIndex = index
        currentTrack = currentPlaylist[index]
        playbackTime = 0
        playbackDuration = 0
        updateNowPlayingInfo()
    }

    private func observeTime() {
        // Ticks only while playing. `sessionSeconds` advances by the tick length,
        // so the trial timer measures real listening time at any interval.
        let tick = 0.25
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: tick, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            self.sessionSeconds += tick
            guard !self.isScrubbing else { return }
            self.playbackTime = time.seconds
            let length = self.player.currentItem?.duration.seconds ?? .nan
            if length.isFinite, length > 0, self.playbackDuration != length {
                self.playbackDuration = length
                self.updateNowPlayingInfo()
            }
        }
    }

    // MARK: – Control Center / Lock Screen

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, self.player.currentItem != nil else { return .noSuchContent }
            if !self.isPlaying { self.togglePlayPause() }
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self, self.isPlaying else { return .commandFailed }
            self.pause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.next()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous()
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard currentTrack != nil else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: currentTrack?.title ?? "His Words",
            MPMediaItemPropertyPlaybackDuration: playbackDuration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: playbackTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let verse = currentTrack?.verse {
            info[MPMediaItemPropertyArtist] = verse
        }
        if let imageName = currentPlaylistImageName, let image = UIImage(named: imageName) {
            let squareImage = image.croppedToSquare()
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: squareImage.size) { _ in squareImage }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

private extension UIImage {
    /// Lock screen and Control Center render `MPMediaItemArtwork` in a square
    /// frame, so a non-square source (e.g. a 4:3 ambience photo) gets
    /// letterboxed there even though it looks fine as a full-bleed player
    /// background. Center-crop to a square before handing it to the artwork API.
    func croppedToSquare() -> UIImage {
        let side = min(size.width, size.height)
        guard side != max(size.width, size.height) else { return self }

        // Some source photos carry an EXIF orientation tag, so the raw
        // `cgImage` pixel buffer doesn't match `size`/`imageOrientation`
        // (e.g. a landscape buffer that's meant to display as portrait).
        // Drawing through `draw(at:)` applies that orientation for us,
        // instead of cropping the unrotated buffer directly.
        let origin = CGPoint(x: (size.width - side) / 2, y: (size.height - side) / 2)
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return renderer.image { _ in
            draw(at: CGPoint(x: -origin.x, y: -origin.y))
        }
    }
}
