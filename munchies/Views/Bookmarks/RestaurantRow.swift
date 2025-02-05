import SwiftUI

struct RestaurantRow: View {
    let restaurant: Restaurant
    var onFavorite: () -> Void
    var onWantToVisit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.headline)
                    
                    Text(restaurant.type)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let address = restaurant.address {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.caption)
                        
                        if !restaurant.isOpen {
                            Text("•")
                                .foregroundColor(.gray)
                            Text("Closed")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: onFavorite) {
                        Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(restaurant.isFavorite ? .red : .gray)
                    }
                    
                    Button(action: onWantToVisit) {
                        Image(systemName: restaurant.wantToVisit ? "bookmark.fill" : "bookmark")
                            .foregroundColor(restaurant.wantToVisit ? .blue : .gray)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
