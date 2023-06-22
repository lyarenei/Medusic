import AVFoundation

extension AVQueuePlayer {
    func clearNextItems() {
        guard currentItem != nil else { return }
        for item in items() where item != currentItem {
            remove(item)
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
