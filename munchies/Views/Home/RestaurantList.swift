import SwiftUI
import GoogleMaps
import GooglePlaces

struct RestaurantList: View {
    let restaurants: [Restaurant]
    @ObservedObject var restaurantService: RestaurantService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Break down the ForEach into a separate view
                RestaurantRows(
                    restaurants: restaurants,
                    restaurantService: restaurantService
                )
                
                // Loading indicator
                if restaurantService.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.bottom, 16)
        }
    }
}

// Separate view for the restaurant rows
private struct RestaurantRows: View {
    let restaurants: [Restaurant]
    @ObservedObject var restaurantService: RestaurantService
    
    var body: some View {
        ForEach(restaurants) { restaurant in
            RestaurantCard(restaurant: restaurant)
                .padding(.horizontal)
                .onAppear {
                    checkLoadMore(for: restaurant)
                }
        }
    }
    
    private func checkLoadMore(for restaurant: Restaurant) {
        // Check if this is the last restaurant
        if let lastRestaurant = restaurants.last,
           restaurant.id == lastRestaurant.id,
           restaurantService.hasMoreData {
            Task {
                try? await restaurantService.loadRestaurantsInView()
            }
        }
    }
}
struct RestaurantList_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantList(
            restaurants: [],
            restaurantService: RestaurantService(locationManager: LocationManager())
        )
    }
}
