// Saved restaurant card design
import SwiftUI

struct SavedRestaurantCard: View {
    let restaurant: BookmarkedRestaurant
    let onFavorite: () -> Void
    let onWantToVisit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Restaurant Image
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(height: 150)
            .cornerRadius(8)
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(restaurant.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.caption)
                }
            }
            
            // Action Buttons
            HStack {
                Button(action: onFavorite) {
                    Label("Favorite", systemImage: restaurant.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(restaurant.isFavorite ? .red : .gray)
                }
                
                Spacer()
                
                Button(action: onWantToVisit) {
                    Label("Want to Visit", systemImage: restaurant.wantToVisit ? "bookmark.fill" : "bookmark")
                        .foregroundColor(restaurant.wantToVisit ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
