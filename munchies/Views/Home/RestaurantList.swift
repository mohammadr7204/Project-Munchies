import SwiftUI
import GoogleMaps
import GooglePlaces

struct RestaurantList: View {
    let restaurants: [Restaurant]
    @ObservedObject var restaurantService: RestaurantService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(restaurants) { restaurant in
                    RestaurantCard(restaurant: restaurant)
                        .padding(.horizontal)
                        .onAppear {
                            // When the last restaurant appears and there is more data to load…
                            if restaurant == restaurants.last, restaurantService.hasMoreData {
                                Task {
                                    try? await restaurantService.loadNextPage()
                                }
                            }
                        }
                }
                
                // Show a loading indicator at the bottom when loading more data.
                if restaurantService.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.bottom, 16)
        }
    }
}

struct RestaurantList_Previews: PreviewProvider {
    static var previews: some View {
        // For preview purposes, initialize with empty data or sample restaurants.
        RestaurantList(
            restaurants: [],
            restaurantService: RestaurantService(locationManager: LocationManager())
        )
    }
}
