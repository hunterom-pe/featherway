import ImageIO
import SwiftUI

struct SightingPhoto: View {
    let url: URL
    let isThumbnail: Bool
    @State private var photo: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: isThumbnail ? .fill : .fit)
            } else if failed {
                Label("Photo unavailable", systemImage: "photo")
            } else {
                ProgressView()
            }
        }
        .task(id: url) {
            let image = await Self.load(url, maximumSize: isThumbnail ? 400 : 2400)
            guard !Task.isCancelled else { return }
            photo = image
            failed = image == nil
        }
    }

    private static func load(_ url: URL, maximumSize: Int) async -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumSize
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: image)
    }
}
