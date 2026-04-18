import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    var height: CGFloat = 220

    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                ZStack {
                    Rectangle()
                        .fill(Color.appSurface)
                    Image(systemName: "photo")
                        .foregroundStyle(Color.appBorder)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .cornerRadius(14)
    }
}
