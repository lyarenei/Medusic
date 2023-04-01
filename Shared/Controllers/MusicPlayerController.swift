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
        if player.isPlaying {
            player.pause()
            playIcon = .pauseFill
        } else {
            player.resume()
            playIcon = .playFill
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
