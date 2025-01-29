// List container for saved restaurants
import SwiftUI

struct BookmarksList: View {
    let restaurants: [BookmarkedRestaurant]
    
    var body: some View {
        if restaurants.isEmpty {
            Text("No bookmarked restaurants yet")
                .foregroundColor(.gray)
        } else {
            List(restaurants) { restaurant in
                RestaurantRow(
                    restaurant: restaurant,
                    onFavorite: {
                        // Add favorite action here
                        print("Favorite tapped for \(restaurant.name)")
                    },
                    onWantToVisit: {
                        // Add want to visit action here
                        print("Want to visit tapped for \(restaurant.name)")
                    }
                )
            }
        }
    }
}
