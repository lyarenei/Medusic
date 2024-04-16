import AVFoundation
import Combine
import SwiftUI

struct PlaybackProgressComponent: View {
    @EnvironmentObject
    private var player: MusicPlayer

    @State
    private var currentTime: TimeInterval = 0

    @State
    private var remainingTime: TimeInterval = 0

    @State
    private var isSeeking = false

    @State
    private var seekPercent = 0.0

    @State
    private var runtime: TimeInterval = 0

    @State
    private var observer: PlayerTimeObserver?

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                progressView
                    .gesture(
                        DragGesture(minimumDistance: 12)
                            .onChanged { value in
                                withAnimation { isSeeking = true }
                                seekPercent = min(1, max(0, value.location.x / geometry.size.width))
                            }
                            .onEnded { _ in
                                withAnimation { isSeeking = false }
                                player.seek(to: seekPercent)
                            }
                    )
            }
            .fixedSize(horizontal: false, vertical: true)

            progressTimes
        }
        .onAppear {
            observer = .init(player: player.player)
            runtime = player.currentSong?.runtime ?? 0
            setTimes(currentTime: player.player.currentTimeRounded)
        }
        .onChange(of: player.currentSong) {
            runtime = player.currentSong?.runtime ?? 0
            setTimes(currentTime: player.player.currentTimeRounded)
        }
    }

    @ViewBuilder
    private var progressView: some View {
        // ZStack is necessary here so that our drag gesture doesn't get yeeted out the window
        // when the `isSeeking` state changes.
        ZStack {
            if isSeeking {
                ProgressView(value: seekPercent, total: 1)
            } else {
                ProgressView(value: currentTime, total: runtime)
            }
        }
        .progressViewStyle(.linear)
        .onReceive(observer?.currentTime) { newValue in
            var curTime = newValue.rounded(.toNearestOrAwayFromZero)
            curTime = curTime > runtime ? runtime : curTime
            setTimes(currentTime: curTime)
        }
        .scaleEffect(x: 1, y: isSeeking ? 3.5 : 1, anchor: .center)
        .animation(.easeInOut, value: isSeeking)
    }

    @ViewBuilder
    private var progressTimes: some View {
        HStack {
            Text(currentTime.timeString)
                .font(.caption)

            Spacer()
            Text(remainingTime.timeString)
                .font(.caption)
        }
    }

    private func setTimes(currentTime: TimeInterval) {
        self.currentTime = currentTime
        remainingTime = runtime - currentTime
    }
}

#if DEBUG
// swiftlint:disable all

#Preview {
    struct Preview: View {
        @State
        var player = PreviewUtils.player

        var body: some View {
            PlaybackProgressComponent()
                .padding(.horizontal)
                .task { player.setCurrentlyPlaying(newSong: PreviewData.songs.first) }
                .environmentObject(ApiClient(previewEnabled: true))
                .environmentObject(PreviewUtils.libraryRepo)
                .environmentObject(player)
        }
    }

    return Preview()
}

// swiftlint:enable all
#endif

/// Observer for playback time.
///
/// Inspired by: https://gist.github.com/ChrisMash/57141446fc18771e541571f89a5cc1c5#file-playertimeview-swift
private class PlayerTimeObserver {
    private var timeObservation: Any?
    private weak var player: AVQueuePlayer?
    let currentTime = PassthroughSubject<TimeInterval, Never>()

    init(player: AVQueuePlayer) {
        self.player = player
        self.timeObservation = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: nil
        ) { [weak self] currentTime in
            guard let self else { return }
            self.currentTime.send(currentTime.seconds)
        }
    }

    deinit {
        if let timeObservation {
            player?.removeTimeObserver(timeObservation)
        }
    }
}
