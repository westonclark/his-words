import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var audio: AudioPlayerService
    let onTap: () -> Void

    var body: some View {
        if let track = audio.currentTrack {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: track.category.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 44, height: 44)
                        Image(systemName: track.category.icon)
                            .foregroundColor(.creamWhite.opacity(0.85))
                            .font(.system(size: 16))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.creamWhite)
                        Text(track.category.displayName)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.mutedCream)
                    }

                    Spacer()

                    Button {
                        audio.togglePlayPause()
                    } label: {
                        Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.creamWhite)
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.charcoal)
                        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
                )
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
    }
}
