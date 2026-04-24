import Foundation
import Combine

final class DownloadService: ObservableObject {
    @Published private(set) var downloadedIDs: Set<UUID> = []
    @Published private(set) var downloadingIDs: Set<UUID> = []

    private var activeTasks: [UUID: URLSessionDownloadTask] = [:]
    private lazy var session = URLSession(configuration: .default)

    init() {
        scanDisk()
    }

    // MARK: – Public API

    func isDownloaded(_ track: Track) -> Bool {
        downloadedIDs.contains(track.id)
    }

    func isDownloading(_ track: Track) -> Bool {
        downloadingIDs.contains(track.id)
    }

    func localURL(for track: Track) -> URL? {
        let url = fileURL(for: track)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func download(_ track: Track) {
        guard !isDownloaded(track), !isDownloading(track),
              let remote = URL(string: track.streamURL) else { return }

        downloadingIDs.insert(track.id)

        let task = session.downloadTask(with: remote) { [weak self] tempURL, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.downloadingIDs.remove(track.id)
                self.activeTasks.removeValue(forKey: track.id)

                guard let tempURL, error == nil else { return }
                let dest = self.fileURL(for: track)
                try? FileManager.default.moveItem(at: tempURL, to: dest)
                self.downloadedIDs.insert(track.id)
            }
        }
        activeTasks[track.id] = task
        task.resume()
    }

    func delete(_ track: Track) {
        activeTasks[track.id]?.cancel()
        activeTasks.removeValue(forKey: track.id)
        downloadingIDs.remove(track.id)
        try? FileManager.default.removeItem(at: fileURL(for: track))
        downloadedIDs.remove(track.id)
    }

    // MARK: – Helpers

    private func fileURL(for track: Track) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(track.id.uuidString).aac")
    }

    private func scanDisk() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: docs, includingPropertiesForKeys: nil
        ) else { return }
        downloadedIDs = Set(
            contents.compactMap { url -> UUID? in
                guard url.pathExtension == "aac" else { return nil }
                return UUID(uuidString: url.deletingPathExtension().lastPathComponent)
            }
        )
    }
}
