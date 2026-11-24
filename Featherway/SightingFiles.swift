import Foundation

struct SightingFiles {
    let directory: URL

    static let local = SightingFiles(directory: URL.applicationSupportDirectory
        .appending(path: "Sightings", directoryHint: .isDirectory))

    func list() throws -> [URL] {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return try FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles
        )
        .filter { $0.pathExtension == "jpg" }
        .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    func save(_ jpeg: Data, at date: Date = .now) throws -> URL {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        let url = directory.appending(path: "\(milliseconds)-\(UUID().uuidString).jpg")
        try jpeg.write(to: url, options: .atomic)
        return url
    }
}
