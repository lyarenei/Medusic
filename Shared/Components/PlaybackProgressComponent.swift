import AVFoundation
import Combine
import SwiftUI

struct PlaybackProgressComponent: View {
    @State
    private var currentTime: TimeInterval = 0

    @State
    private var remainingTime: TimeInterval

    @State
    private var isSeeking = false

    @State
    private var seekPercent = 0.0

    private let runtime: TimeInterval
    private var observer: PlayerTimeObserver
    private var player: MusicPlayer

    init(player: MusicPlayer = .shared) {
        self.runtime = player.currentSong?.runtime ?? 0
        self.remainingTime = runtime
        self.observer = .init(player: player.player)
        self.player = player
    }

    // swiftlint:disable closure_body_length
    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                progressView
                    .progressViewStyle(.linear)
                    .onReceive(observer.publisher) { newValue in
                        var curTime = newValue.rounded(.toNearestOrAwayFromZero)
                        curTime = curTime > runtime ? runtime : curTime
                        setTimes(currentTime: curTime)
                    }
                    .onAppear { setTimes(currentTime: player.player.currentTimeRounded) }
                    .scaleEffect(x: 1, y: isSeeking ? 3.5 : 1, anchor: .center)
                    .animation(.easeInOut, value: isSeeking)
                    .gesture(
                        DragGesture(minimumDistance: 12)
                            .onChanged { value in
                                withAnimation { isSeeking = true }
                                seekPercent = min(1, max(0, value.location.x / geometry.size.width))
                            }
                            .onEnded { _ in
                                withAnimation { isSeeking = false }
                                player.seek(percent: seekPercent)
                            }
                    )
            }
            .fixedSize(horizontal: false, vertical: true)

            progressTimes
        }
    }

    // swiftlint:enable closure_body_length

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
struct PlaybackProgressComponent_Previews: PreviewProvider {
    static var player: MusicPlayer {
        let mp = MusicPlayer(preview: true)
        mp.currentSong = PreviewData.songs.first!
        return mp
    }

    static var previews: some View {
        PlaybackProgressComponent(player: player)
    }
}
// swiftlint:enable all
#endif

/// Observer for playback time.
///
/// Inspired by: https://gist.github.com/ChrisMash/57141446fc18771e541571f89a5cc1c5#file-playertimeview-swift
private class PlayerTimeObserver {
    private var timeObservation: Any?
    private weak var player: AVQueuePlayer?
    let publisher = PassthroughSubject<TimeInterval, Never>()

    init(player: AVQueuePlayer) {
        self.player = player
        self.timeObservation = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: nil
        ) { [weak self] currentTime in
            guard let self else { return }
            self.publisher.send(currentTime.seconds)
        }
    }

    deinit {
        if let timeObservation {
            player?.removeTimeObserver(timeObservation)
        }
    }
}
