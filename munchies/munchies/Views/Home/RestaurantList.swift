import SwiftUI
import MapKit

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
        RestaurantList(restaurants: Restaurant.sampleData)
    }
}
