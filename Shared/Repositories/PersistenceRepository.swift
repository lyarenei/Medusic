import AVFoundation
import Boutique
import Foundation
import OSLog

final class PersistenceRepository: ObservableObject {
    public static var shared = PersistenceRepository(store: .playbackQueue)

    @Stored
    var playbackQueue: [PlayerQueueItem]

    init(
        store: Store<PlayerQueueItem> = .playbackQueue
    ) {
        _playbackQueue = Stored(in: store)
    }

    public func save(_ currentQueue: [AVJellyPlayerItem]) async {
        let orderedItems = currentQueue.enumerated().compactMap { (idx: Int, item: AVJellyPlayerItem) -> PlayerQueueItem? in
            guard let uuid = item.song?.uuid, let url = item.url else { return nil }
            return PlayerQueueItem(songUuid: uuid, songUrl: url, orderIndex: idx)
        }

        do {
            try await $playbackQueue.removeAll().insert(orderedItems).run()
        } catch {
            Logger.repository.error("Could not persist playback queue: \(error.localizedDescription)")
        }
    }
}
