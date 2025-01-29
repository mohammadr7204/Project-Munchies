import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isBottomSheetExpanded = false
    @State private var searchText = ""
    @State private var restaurants = Restaurant.sampleData
    @State private var selectedRestaurant: Restaurant?
    @State private var isLoading = false
    @State private var zoomIncrement = 0.05
    @State private var zoomLevel = 0.05

    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        }
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText) ||
            restaurant.type.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            // Map View
            Map(coordinateRegion: $locationManager.region,
                showsUserLocation: true,
                annotationItems: filteredRestaurants) { restaurant in
                    MapMarker(coordinate: restaurant.coordinate,
                              tint: selectedRestaurant?.id == restaurant.id ? .blue : .red)
            }
            .ignoresSafeArea()
            

            // Overlay for SearchBar and Zoom Controls
            VStack(spacing: 8) {
                // Search Bar
                HStack {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                
                // Zoom Controls right under search bar
                HStack {
                    Spacer() // Push buttons to the right
                    VStack(spacing: 8) { // Changed back to VStack for vertical layout
                        Button(action: {
                            withAnimation {
                                zoomLevel = max(0.01, zoomLevel - zoomIncrement)
                                locationManager.region.span = MKCoordinateSpan(
                                    latitudeDelta: zoomLevel,
                                    longitudeDelta: zoomLevel
                                )
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 2)
                        }

                        Button(action: {
                            withAnimation {
                                zoomLevel = min(0.2, zoomLevel + zoomIncrement)
                                locationManager.region.span = MKCoordinateSpan(
                                    latitudeDelta: zoomLevel,
                                    longitudeDelta: zoomLevel
                                )
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.trailing, 16) // Padding from the right edge
                }
                .padding(.horizontal, 16)
                
                Spacer() // Push everything else to the bottom
            }
            .frame(maxWidth: .infinity, alignment: .top)

                        
            
            // Bottom Sheet
            BottomSheet(isExpanded: $isBottomSheetExpanded) {
                RestaurantList(restaurants: filteredRestaurants)
            }
            .ignoresSafeArea(.keyboard)
            
        }
    }
    
    // Custom annotation view
    struct RestaurantAnnotation: View {
        let restaurant: Restaurant
        let isSelected: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .blue : .red)
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .offset(x: 0, y: -5)
                    .foregroundColor(isSelected ? .blue : .red)
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .animation(.easeInOut, value: isSelected)
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
}
