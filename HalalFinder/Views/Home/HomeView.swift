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
            // Map View with annotations
            Map(coordinateRegion: $locationManager.region,
                annotationItems: filteredRestaurants) { restaurant in
                MapAnnotation(coordinate: restaurant.coordinate) {
                    RestaurantAnnotation(
                        restaurant: restaurant,
                        isSelected: selectedRestaurant?.id == restaurant.id
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedRestaurant = restaurant
                            isBottomSheetExpanded = true
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Search Bar at top
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
                
                Spacer()
            }
            
            // Bottom Sheet
            VStack {
                Spacer()
                BottomSheet(isExpanded: $isBottomSheetExpanded) {
                    RestaurantList()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
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
