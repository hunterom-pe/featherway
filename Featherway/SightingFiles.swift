import Foundation

struct SightingLocation: Codable {
    let course: String
    let hole: Int?

    init?(course: String, hole: Int?) {
        self.course = course.trimmingCharacters(in: .whitespacesAndNewlines)
        self.hole = hole.flatMap { (1...18).contains($0) ? $0 : nil }
        if self.course.isEmpty && self.hole == nil { return nil }
    }
}

struct SightingFiles {
    let directory: URL

    static let local = SightingFiles(directory: URL.applicationSupportDirectory
        .appending(path: "Sightings", directoryHint: .isDirectory))

    func list() throws -> [URL] {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return try FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles
        )
        .compactMap { entry -> URL? in
            if entry.pathExtension == "jpg" { return entry }
            guard entry.pathExtension == "sighting" else { return nil }
            return entry.appending(path: entry.deletingPathExtension().lastPathComponent + ".jpg")
        }
        .sorted { $0.lastPathComponent > $1.lastPathComponent }
    }

    func save(_ jpeg: Data, name: String = "", location: SightingLocation? = nil, at date: Date = .now) throws -> URL {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        let id = "\(milliseconds)-\(UUID().uuidString)"
        let filename = id + ".jpg"
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && location == nil {
            let url = directory.appending(path: filename)
            try jpeg.write(to: url, options: .atomic)
            return url
        }

        // Publish the photo and its details together. Incomplete folders stay out of the collection.
        let staging = directory.appending(path: "." + id, directoryHint: .isDirectory)
        let destination = directory.appending(path: id + ".sighting", directoryHint: .isDirectory)
        let files = FileManager.default
        try files.createDirectory(at: staging, withIntermediateDirectories: false)
        defer { try? files.removeItem(at: staging) }
        try jpeg.write(to: staging.appending(path: filename))
        if !trimmed.isEmpty {
            try trimmed.write(to: staging.appending(path: "name.txt"), atomically: false, encoding: .utf8)
        }
        if let location {
            let data = try JSONEncoder().encode(location)
            try data.write(to: staging.appending(path: "location.json"))
        }
        try files.moveItem(at: staging, to: destination)
        return destination.appending(path: filename)
    }

    static func savedAt(for photo: URL) -> Date? {
        let filename = photo.deletingPathExtension().lastPathComponent
        guard let separator = filename.firstIndex(of: "-"),
              let milliseconds = Int64(filename[..<separator]) else { return nil }
        return Date(timeIntervalSince1970: Double(milliseconds) / 1000)
    }

    static func location(for photo: URL) -> SightingLocation? {
        let folder = photo.deletingLastPathComponent()
        guard folder.pathExtension == "sighting",
              let data = try? Data(contentsOf: folder.appending(path: "location.json")) else { return nil }
        return try? JSONDecoder().decode(SightingLocation.self, from: data)
    }

    static func birdName(for photo: URL) -> String? {
        let folder = photo.deletingLastPathComponent()
        guard folder.pathExtension == "sighting" else { return nil }
        return try? String(contentsOf: folder.appending(path: "name.txt"), encoding: .utf8)
    }
}
