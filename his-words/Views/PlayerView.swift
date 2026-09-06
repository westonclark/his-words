import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGFloat = 0

    private let dismissThreshold: CGFloat = 140

    var body: some View {
        ZStack {
            Color.warmBlack.ignoresSafeArea()

            if let imageName = audio.currentPlaylistImageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .clipped() // Cuts off the horizontal overflow
                    .ignoresSafeArea()
                    .overlay {
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(0.15), location: 0),
                                .init(color: .black.opacity(0.5),  location: 0.5),
                                .init(color: .black.opacity(0.88), location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    }
            } else {
                backgroundGradient
            }

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    dragHandle

                    Spacer()

                    if let track = audio.currentTrack {
                        trackInfo(track: track)
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
                .gesture(dismissDrag)

                if let context = audio.context, context.topic.hasVoiceOptions {
                    voiceOptions(context: context)
                }

                progressBar

                controls
                    .padding(.bottom, 48)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
        }
        .offset(y: dragOffset)
        .animation(.interactiveSpring(), value: dragOffset)
        .onChange(of: trial.hasExhaustedTrial) { _, exhausted in
            if exhausted {
                audio.pause()
                dismiss()
                appState.showPaywall = true
            }
        }
    }

    // MARK: – Subviews

    private var backgroundGradient: some View {
        Group {
            if let track = audio.currentTrack {
                LinearGradient(
                    colors: [track.category.gradient[1], Color.warmBlack],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                Color.warmBlack
            }
        }
        .ignoresSafeArea()
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.creamWhite.opacity(0.25))
            .frame(width: 36, height: 5)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
    }

    private var dismissDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = max(0, value.translation.height)
            }
            .onEnded { value in
                if value.translation.height > dismissThreshold {
                    dismiss()
                } else {
                    dragOffset = 0
                }
            }
    }

    private func trackInfo(track: Track) -> some View {
        VStack(spacing: 8) {
            Text(track.title)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.creamWhite)
                .minimumScaleFactor(0.7)

            if let verse = track.verse {
                Text(verse)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.creamWhite.opacity(0.72))
            }

            if audio.currentPlaylistTotalCount > 1 {
                Text("\(audio.currentIndex + 1) of \(audio.currentPlaylistTotalCount)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.creamWhite.opacity(0.45))
                    .padding(.top, 2)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 8)
    }

    /// Narrator and 1st/2nd-person toggles. Changing the voice restarts the
    /// current track; changing person restarts the set, since the two
    /// recordings don't line up track for track.
    private func voiceOptions(context: PlaybackContext) -> some View {
        // Three equal spacers so the outer margins match the gap between the two.
        HStack(spacing: 0) {
            Spacer(minLength: 12)

            SegmentedToggle(
                options: VoiceOption.allCases,
                selection: context.voice,
                label: \.label
            ) { audio.setVoice($0) }

            Spacer(minLength: 12)

            SegmentedToggle(
                options: PersonOption.allCases,
                selection: context.person,
                label: \.label
            ) { audio.setPerson($0) }

            Spacer(minLength: 12)
        }
        .padding(.horizontal, -24)  // cancel the parent inset so margins measure from the screen edge
        .padding(.bottom, 28)
    }

    /// Subscribers get a scrubber; everyone else gets the trial countdown in
    /// the same slot, so the layout below doesn't shift between the two.
    @ViewBuilder
    private var progressBar: some View {
        if !trial.isSubscribed {
            trialProgress
        } else if audio.currentTrack?.isLoop == true {
            // A loop has no meaningful position to show — leave the slot empty
            // so the controls don't shift when a scrubber would have been here.
            Color.clear.frame(height: 12)
        } else {
            scrubber
        }
    }

    private var scrubber: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let duration = audio.playbackDuration
                let fraction = duration > 0
                    ? min(max(audio.playbackTime / duration, 0), 1)
                    : 0
                let filled = geo.size.width * CGFloat(fraction)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.creamWhite.opacity(0.2))
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.creamWhite.opacity(0.9))
                        .frame(width: filled, height: 4)
                    Circle()
                        .fill(Color.creamWhite)
                        .frame(width: 10, height: 10)
                        .offset(x: filled - 5)
                        .opacity(duration > 0 ? 1 : 0)
                }
                .frame(height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard duration > 0 else { return }
                            audio.beginScrub(to: seconds(at: value.location.x, width: geo.size.width, duration: duration))
                        }
                        .onEnded { value in
                            guard duration > 0 else { return }
                            audio.endScrub(to: seconds(at: value.location.x, width: geo.size.width, duration: duration))
                        }
                )
            }
            .frame(height: 22)

            HStack {
                Text(formatTime(audio.playbackTime))
                Spacer()
                Text(audio.playbackDuration > 0
                     ? "-" + formatTime(max(audio.playbackDuration - audio.playbackTime, 0))
                     : "--:--")
            }
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(.creamWhite.opacity(0.55))
            .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
    }

    private func seconds(at x: CGFloat, width: CGFloat, duration: TimeInterval) -> TimeInterval {
        guard width > 0 else { return 0 }
        return duration * TimeInterval(min(max(x / width, 0), 1))
    }

    private var trialProgress: some View {
        Group {
            if !trial.isSubscribed {
                VStack(spacing: 6) {
                    let remaining = trial.remainingFreeSeconds
                    let fraction  = remaining / TrialService.freeLimit

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.charcoal)
                            Capsule()
                                .fill(fraction > 0.3 ? Color.mutedGold : Color.red.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(fraction))
                        }
                        .frame(height: 4)
                    }
                    .frame(height: 4)

                    Text(remaining > 0
                         ? "\(formatTime(remaining)) free remaining"
                         : "Free time used — subscribe to continue")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.mutedCream)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
        }
    }

    /// No close button — the sheet's own swipe-down handles dismissal.
    private var controls: some View {
        HStack {
            // Balances the loop button on the trailing edge so the transport
            // trio in the middle stays centered instead of drifting left.
            Color.clear.frame(width: 44, height: 44)

            Spacer()

            HStack(spacing: 40) {
                Button {
                    audio.previous()
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 22))
                        .foregroundColor(hasMultipleTracks ? .creamWhite : .creamWhite.opacity(0.25))
                        .frame(width: 44, height: 44)
                }
                .disabled(!hasMultipleTracks)

                Button {
                    audio.togglePlayPause()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.creamWhite)
                            .frame(width: 68, height: 68)
                        Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.warmBlack)
                            .offset(x: audio.isPlaying ? 0 : 2)
                    }
                }

                Button {
                    audio.next()
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 22))
                        .foregroundColor(hasMultipleTracks ? .creamWhite : .creamWhite.opacity(0.25))
                        .frame(width: 44, height: 44)
                }
                .disabled(!hasMultipleTracks)
            }

            Spacer()

            Button {
                audio.toggleLoop()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 22))
                    .foregroundColor(audio.isLooping ? .mutedGold : .creamWhite.opacity(0.45))
                    .frame(width: 44, height: 44)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var hasMultipleTracks: Bool { audio.currentPlaylist.count > 1 }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: – Segmented toggle

private struct SegmentedToggle<Option: Identifiable & Equatable>: View {
    let options: [Option]
    let selection: Option
    let label: KeyPath<Option, String>
    let onSelect: (Option) -> Void

    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options) { option in
                let isSelected = option == selection
                Button {
                    onSelect(option)
                } label: {
                    Text(option[keyPath: label])
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected ? .creamWhite : .creamWhite.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.creamWhite.opacity(0.16))
                                    .matchedGeometryEffect(id: "indicator", in: indicator)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Capsule().fill(.ultraThinMaterial))
        .environment(\.colorScheme, .dark)
        .overlay(Capsule().stroke(Color.creamWhite.opacity(0.1), lineWidth: 1))
        .animation(.snappy(duration: 0.25), value: selection)
    }
}
