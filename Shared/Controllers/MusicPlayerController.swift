import Foundation
import SFSafeSymbols
import SwiftUI

@MainActor
final class MusicPlayerController: ObservableObject {
    @ObservedObject
    var player: MusicPlayer = .shared

    @Published
    var playIcon: SFSymbol = .playFill

    func onPlayPauseButton() {
        Task {
            let nextIcon: SFSymbol
            if player.isPlaying {
                await player.pause()
                nextIcon = .pauseFill
            } else {
                await player.resume()
                nextIcon = .playFill
            }
            await MainActor.run {
                playIcon = nextIcon
            }
        }
    }

    func onSkipForward() {
        Task(priority: .userInitiated) {
            do {
                try await player.skipForward()
            } catch {
                print("Skip forward failed")
            }
        }
    }

    func onSkipBackward() {

    }
}
