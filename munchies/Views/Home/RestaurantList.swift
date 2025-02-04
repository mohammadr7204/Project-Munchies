import SwiftUI
import GoogleMaps
import GooglePlaces

struct RestaurantList: View {
    let restaurants: [Restaurant]
    
    var body: some View {
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

struct RestaurantList_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantList(restaurants: [
            Restaurant(name: "Test Restaurant", type: "Halal", rating: 4.5, distance: 1.0, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        ])
    }
}
