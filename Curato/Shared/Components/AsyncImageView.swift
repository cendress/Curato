import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    var height: CGFloat = 220
    var cornerRadius: CGFloat = 14

    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                ShimmerPlaceholderView(cornerRadius: cornerRadius)
            case .failure:
                ZStack {
                    ShimmerPlaceholderView(cornerRadius: cornerRadius)
                }
            @unknown default:
                ShimmerPlaceholderView(cornerRadius: cornerRadius)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .cornerRadius(cornerRadius)
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
