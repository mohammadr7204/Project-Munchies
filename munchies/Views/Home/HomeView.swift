//HomeView
import SwiftUI
import GoogleMaps
import GooglePlaces
import FirebaseFirestore
import Combine
import CoreLocation

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var camera: GMSCameraPosition
    
    override init() {
        // Initialize camera with a default position
        self.camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: 15.0
        )
    }
}

struct GoogleMapView: UIViewRepresentable {
    @Binding var camera: GMSCameraPosition
    let markers: [Restaurant]
    let onMarkerTap: (Restaurant) -> Void
    
    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = camera
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        
        updateMarkers(mapView: mapView)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.camera = camera
        updateMarkers(mapView: mapView)
    }
    
    private func updateMarkers(mapView: GMSMapView) {
        mapView.clear()
        markers.forEach { restaurant in
            let marker = GMSMarker(position: restaurant.coordinate)
            marker.title = restaurant.name
            marker.snippet = restaurant.type
            marker.map = mapView
            marker.userData = restaurant
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let restaurant = marker.userData as? Restaurant {
                parent.onMarkerTap(restaurant)
            }
            return true
        }
    }
}

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantService: RestaurantService
    @State private var isBottomSheetExpanded = false
    @State private var searchText = ""
    @State private var selectedRestaurant: Restaurant?
    @State private var errorMessage: ErrorMessage?
    
    private let db = Firestore.firestore()
    private let placesClient = GMSPlacesClient.shared()
    
    init() {
        let tempLocationManager = LocationManager()
        let service = RestaurantService(locationManager: tempLocationManager)
        _restaurantService = StateObject(wrappedValue: service)
    }
    
    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty { return restaurantService.restaurants }
        return restaurantService.restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText) ||
            restaurant.type.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            GoogleMapView(
                camera: $locationManager.camera,
                markers: filteredRestaurants
            ) { restaurant in
                selectedRestaurant = restaurant
                isBottomSheetExpanded = true
            }
            .ignoresSafeArea()
            
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                mapControls
                
                Spacer()
            }
            
            BottomSheet(isExpanded: $isBottomSheetExpanded) {
                RestaurantList(
                    restaurants: filteredRestaurants,
                    restaurantService: restaurantService
                )
            }
            
            if restaurantService.isLoading && restaurantService.restaurants.isEmpty {
                loadingOverlay
            }
        }
        .alert(item: $errorMessage) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            fetchRestaurants()
        }
    }
    
    private var mapControls: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                MapButton(systemName: "plus.circle.fill") {
                    updateZoom(by: 1.0)
                }
                
                MapButton(systemName: "minus.circle.fill") {
                    updateZoom(by: -1.0)
                }
            }
            .padding(.trailing, 16)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Loading Restaurants...")
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
        }
        .ignoresSafeArea()
    }
    
    private func updateZoom(by delta: Double) {
        let newZoom = max(10.0, min(20.0, Double(locationManager.camera.zoom) + delta))
        locationManager.camera = GMSCameraPosition(
            target: locationManager.camera.target,
            zoom: Float(newZoom)
        )
    }
    
    private func fetchRestaurants() {
        Task {
            do {
                try await restaurantService.loadFirstPage()
            } catch {
                errorMessage = ErrorMessage(message: error.localizedDescription)
            }
        }
    }
}

private struct MapButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 35))
                .foregroundColor(.blue)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}
