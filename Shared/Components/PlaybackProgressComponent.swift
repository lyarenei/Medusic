import AVFoundation
import Combine
import SwiftUI

struct PlaybackProgressComponent: View {
    @State
    private var currentTime: TimeInterval = 0

    @State
    private var remainingTime: TimeInterval

    private let runtime: TimeInterval
    private var observer: PlayerTimeObserver

    init(player: MusicPlayer = .shared) {
        self.runtime = player.currentSong?.runtime ?? 0
        self.remainingTime = runtime
        self.observer = .init(player: player.player)
    }

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: currentTime, total: runtime)
                .progressViewStyle(.linear)
                .padding(.bottom, 10)
                .padding(.top, 15)
                .onReceive(observer.publisher) { newValue in
                    var curTime = newValue.rounded(.toNearestOrAwayFromZero)
                    curTime = curTime > runtime ? runtime : curTime
                    currentTime = curTime
                    remainingTime = runtime - curTime
                }

            HStack {
                Text(currentTime.timeString)
                    .font(.caption)

                Spacer()
                Text(remainingTime.timeString)
                    .font(.caption)
            }
        }
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
