import SwiftUI

struct RestaurantList: View {
    // Sample data - In a real app, this would come from a data service
    @State private var restaurants = [
        Restaurant(
            name: "Halal Guys",
            type: "Middle Eastern",
            rating: 4.5,
            distance: 0.8,
            isOpen: true,
            imageUrl: nil
        ),
        Restaurant(
            name: "Mediterranean Cuisine",
            type: "Mediterranean",
            rating: 4.2,
            distance: 1.2,
            isOpen: true,
            imageUrl: nil
        ),
        Restaurant(
            name: "Istanbul Kebab",
            type: "Turkish",
            rating: 4.7,
            distance: 1.5,
            isOpen: true,
            imageUrl: nil
        ),
        Restaurant(
            name: "Shawarma House",
            type: "Middle Eastern",
            rating: 4.3,
            distance: 1.8,
            isOpen: false,
            imageUrl: nil
        ),
        Restaurant(
            name: "Falafel King",
            type: "Middle Eastern",
            rating: 4.1,
            distance: 2.0,
            isOpen: true,
            imageUrl: nil
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Nearby Restaurants")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Filter button (to be implemented)
                Button(action: {
                    // Add filter action
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.primary)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            // Restaurant list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(restaurants) { restaurant in
                        RestaurantCard(restaurant: restaurant)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
}

struct RestaurantList_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantList()
    }
}
