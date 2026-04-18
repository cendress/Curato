import SwiftUI
import UIKit

private final class ImageMemoryCache {
    static let shared = ImageMemoryCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 400
    }

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func store(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

struct AsyncImageView: View {
    let urlString: String?
    var height: CGFloat = 220
    var cornerRadius: CGFloat = 14

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var didFail = false

    private var normalizedURLString: String? {
        let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else if isLoading || !didFail {
                ShimmerPlaceholderView(cornerRadius: cornerRadius)
            } else {
                ShimmerPlaceholderView(cornerRadius: cornerRadius)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .cornerRadius(cornerRadius)
        .task(id: normalizedURLString) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        guard let key = normalizedURLString else {
            image = nil
            isLoading = false
            didFail = true
            return
        }

        if let cached = ImageMemoryCache.shared.image(forKey: key) {
            image = cached
            isLoading = false
            didFail = false
            return
        }

        image = nil
        isLoading = true
        didFail = false

        guard let url = URL(string: key) else {
            isLoading = false
            didFail = true
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200 ... 299).contains(httpResponse.statusCode),
                let decoded = UIImage(data: data)
            else {
                throw URLError(.badServerResponse)
            }

            ImageMemoryCache.shared.store(decoded, forKey: key)

            guard normalizedURLString == key else {
                return
            }

            image = decoded
            isLoading = false
            didFail = false
        } catch {
            guard normalizedURLString == key else {
                return
            }

            image = nil
            isLoading = false
            didFail = true
        }
    }
}

#Preview {
    VStack(spacing: 14) {
        AsyncImageView(urlString: "https://example.com/does-not-resolve.jpg", height: 220)
        AsyncImageView(urlString: nil, height: 120, cornerRadius: 12)
    }
    .padding()
    .background(Color.appBackground)
}
