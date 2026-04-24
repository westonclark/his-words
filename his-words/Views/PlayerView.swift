import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var audio: AudioPlayerService
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                dragHandle

                Spacer()

                if let track = audio.currentTrack {
                    BreathingCircleView(gradient: track.category.gradient)
                        .padding(.bottom, 16)

                    trackInfo(track: track)
                }

                Spacer()

                trialProgress

                controls

                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 24)
        }
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
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    private func trackInfo(track: Track) -> some View {
        VStack(spacing: 6) {
            Text(track.title)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundColor(.creamWhite)
            Text(track.category.displayName)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.mutedCream)

            if audio.currentPlaylist.count > 1 {
                Text("\(audio.currentIndex + 1) of \(audio.currentPlaylist.count)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.mutedCream.opacity(0.7))
                    .padding(.top, 2)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 8)
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

    private var controls: some View {
        HStack(spacing: 0) {
            // Close
            Button {
                audio.stop()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.creamWhite.opacity(0.45))
                    .frame(maxWidth: .infinity)
            }

            // Previous
            Button {
                audio.previous()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 22))
                    .foregroundColor(audio.currentPlaylist.count > 1 ? .creamWhite : .creamWhite.opacity(0.25))
                    .frame(maxWidth: .infinity)
            }
            .disabled(audio.currentPlaylist.count <= 1)

            // Play / Pause
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
                .frame(maxWidth: .infinity)
            }

            // Next
            Button {
                audio.next()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 22))
                    .foregroundColor(audio.currentPlaylist.count > 1 ? .creamWhite : .creamWhite.opacity(0.25))
                    .frame(maxWidth: .infinity)
            }
            .disabled(audio.currentPlaylist.count <= 1)

            // Loop toggle
            Button {
                audio.toggleLoop()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 22))
                    .foregroundColor(audio.isLooping ? .mutedGold : .creamWhite.opacity(0.45))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
