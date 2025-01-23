import SwiftUI
import MapKit

struct RestaurantCard: View {
    let restaurant: Restaurant
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Restaurant Image
                ZStack {
                    if let _ = restaurant.imageUrl {
                        // In a real app, you'd use AsyncImage or load from URL
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                // Restaurant Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(restaurant.type)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                        }
                        .font(.subheadline)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        // Distance
                        Text(String(format: "%.1f mi", restaurant.distance))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        // Open/Closed Status
                        Text(restaurant.isOpen ? "Open" : "Closed")
                            .font(.subheadline)
                            .foregroundColor(restaurant.isOpen ? .green : .red)
                    }
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title3)
                }
                .padding(.trailing, 4)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RestaurantCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
            VStack {
                RestaurantCard(restaurant: Restaurant(
                    name: "Halal Guys",
                    type: "Middle Eastern",
                    rating: 4.5,
                    distance: 0.8,
                    isOpen: true,
                    imageUrl: nil, coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                ))
                .padding()
                
                RestaurantCard(restaurant: Restaurant(
                    name: "Mediterranean Cuisine",
                    type: "Mediterranean",
                    rating: 4.2,
                    distance: 1.2,
                    isOpen: false,
                    imageUrl: nil, coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                ))
                .padding()
            }
        }
    }
}
