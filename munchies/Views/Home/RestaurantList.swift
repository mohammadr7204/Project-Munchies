//RestaurantList
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
                            if restaurant == restaurants.last && restaurantService.hasMoreData {
                                Task {
                                    try? await restaurantService.loadNextPage()
                                }
                            }
                        }
                }
                
                if restaurantService.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.bottom, 16)
        }
    }
}
