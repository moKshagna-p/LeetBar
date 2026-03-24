import AppKit
import SwiftUI

private final class LeetImageCache {
    static let shared = NSCache<NSURL, NSImage>()
}

@MainActor
private final class LeetImageLoader: ObservableObject {
    @Published var image: NSImage?
    @Published var isLoading = false

    func load(from candidates: [URL]) {
        guard !candidates.isEmpty else {
            image = nil
            isLoading = false
            return
        }

        isLoading = true
        Task {
            for url in candidates {
                let nsURL = url as NSURL
                if let cached = LeetImageCache.shared.object(forKey: nsURL) {
                    self.image = cached
                    self.isLoading = false
                    return
                }

                var request = URLRequest(url: url)
                request.setValue("https://leetcode.com", forHTTPHeaderField: "Referer")
                request.setValue(
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko)",
                    forHTTPHeaderField: "User-Agent"
                )

                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    guard
                        let http = response as? HTTPURLResponse,
                        (200...299).contains(http.statusCode),
                        let nsImage = NSImage(data: data)
                    else {
                        continue
                    }

                    LeetImageCache.shared.setObject(nsImage, forKey: nsURL)
                    self.image = nsImage
                    self.isLoading = false
                    return
                } catch {
                    continue
                }
            }
            self.image = nil
            self.isLoading = false
        }
    }
}

struct LeetRemoteImage<Placeholder: View>: View {
    let urls: [URL]
    let contentMode: ContentMode
    @ViewBuilder var placeholder: () -> Placeholder

    @StateObject private var loader = LeetImageLoader()

    init(
        urls: [URL],
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urls = urls
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(nsImage: image)
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if loader.isLoading {
                ProgressView()
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load(from: urls)
        }
        .onChange(of: urls.map(\.absoluteString).joined(separator: "|")) { _, _ in
            loader.load(from: urls)
        }
    }
}
