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
                        if let imageName = audio.currentPlaylistImageName,
                           let uiImage = UIImage(named: imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: track.category.icon)
                                .foregroundColor(.creamWhite.opacity(0.85))
                                .font(.system(size: 16))
                        }
                        if audio.isPlaying {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.28))
                                .frame(width: 44, height: 44)
                            Image(systemName: "waveform")
                                .foregroundColor(.creamWhite.opacity(0.9))
                                .font(.system(size: 16))
                                .symbolEffect(.variableColor.iterative, isActive: true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.creamWhite)
                        Text(track.verse ?? track.category.displayName)
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
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.creamWhite.opacity(0.10), lineWidth: 1)
                )
                .environment(\.colorScheme, .dark)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
    }
}
