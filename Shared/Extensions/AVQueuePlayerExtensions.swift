import AVFoundation

extension AVQueuePlayer {
    func clearNextItems(upTo: Int? = nil) {
        guard currentItem != nil else { return }
        if let upTo {
            let currentQueue = items()
            let newQueue = currentQueue.dropFirst(upTo + 1)
            clearNextItems()
            append(items: newQueue)
        } else {
            for item in items() where item != currentItem {
                remove(item)
            }
        }
    }

    func append(item: AVPlayerItem) {
        insert(item, after: nil)
    }

    func append(items: [AVPlayerItem]) {
        for item in items where canInsert(item, after: nil) {
            insert(item, after: nil)
        }
    }

    /// Appends multiple items at the end of queue.
    func append(items: ArraySlice<AVPlayerItem>) {
        for item in items where canInsert(item, after: nil) {
            insert(item, after: nil)
        }
    }

    func prepend(item: AVPlayerItem) {
        insert(item, after: currentItem)
    }

    func prepend(items: [AVPlayerItem]) {
        let currentItems = self.items()
        clearNextItems()

        for item in items where canInsert(item, after: nil) {
            insert(item, after: nil)
        }

        for avItem in currentItems where canInsert(avItem, after: nil) {
            insert(avItem, after: nil)
        }
    }

    var currentTimeRounded: TimeInterval {
        currentTime().seconds.rounded(.toNearestOrAwayFromZero)
    }
}
