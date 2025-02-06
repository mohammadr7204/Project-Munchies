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
        if let location = locationManager.location {
            self.camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 15.0
            )
        } else {
            self.camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 15.0)
        }
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location
        self.camera = GMSCameraPosition(target: location.coordinate, zoom: 15.0)
        locationManager.stopUpdatingLocation()
    }
    
    func recenterMap() {
        if let location = location {
            camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                zoom: 15.0
            )
        }
    }
}

struct GoogleMapView: UIViewRepresentable {
    @Binding var camera: GMSCameraPosition
    let markers: [Restaurant]
    let onMarkerTap: (Restaurant) -> Void
    let onCameraIdle: (GMSVisibleRegion) -> Void
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: .zero)
        mapView.camera = camera
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.zoomGestures = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if mapView.camera != camera {
            mapView.animate(to: camera)
        }
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
                DispatchQueue.main.async {
                    self.parent.onMarkerTap(restaurant)
                }
            }
            return true
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            parent.camera = position
            parent.onCameraIdle(mapView.projection.visibleRegion())
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
    
    init() {
        let tempLocationManager = LocationManager()
        let service = RestaurantService(locationManager: tempLocationManager)
        _restaurantService = StateObject(wrappedValue: service)
    }
    
    var body: some View {
        ZStack {
            GoogleMapView(
                camera: $locationManager.camera,
                markers: filteredRestaurants,
                onMarkerTap: { restaurant in
                    withAnimation(.spring()) {
                        selectedRestaurant = restaurant
                        isBottomSheetExpanded = true
                        // Center map on selected restaurant
                        locationManager.camera = GMSCameraPosition(
                            target: restaurant.coordinate,
                            zoom: locationManager.camera.zoom
                        )
                    }
                },
                onCameraIdle: { region in
                    restaurantService.visibleRegion = region
                    Task {
                        try? await restaurantService.loadRestaurantsInView()
                    }
                }
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    SearchBar(text: $searchText)
                    
                    HStack(spacing: 8) {
                        Spacer()
                        
                        MapButton(systemName: "location.fill") {
                            locationManager.recenterMap()
                        }
                        
                        MapButton(systemName: "plus.circle.fill") {
                            updateCamera(zoom: min(20, locationManager.camera.zoom + 1))
                        }
                        
                        MapButton(systemName: "minus.circle.fill") {
                            updateCamera(zoom: max(10, locationManager.camera.zoom - 1))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
            }
            
            BottomSheet(isExpanded: $isBottomSheetExpanded) {
                VStack {
                    if let selected = selectedRestaurant {
                        VStack {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedRestaurant = nil
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back to List")
                                    }
                                    .foregroundColor(.blue)
                                }
                                .padding(.leading)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            
                            RestaurantCard(restaurant: selected)
                                .padding(.horizontal)
                        }
                    } else {
                        RestaurantList(
                            restaurants: filteredRestaurants,
                            restaurantService: restaurantService
                        )
                    }
                }
            }
            
            if restaurantService.isLoading {
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
    }
    
    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurantService.restaurants
        }
        return restaurantService.restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText) ||
            restaurant.type.localizedCaseInsensitiveContains(searchText)
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
    
    private func updateCamera(zoom: Float? = nil, target: CLLocationCoordinate2D? = nil) {
        let newZoom = zoom ?? locationManager.camera.zoom
        let newTarget = target ?? locationManager.camera.target
        locationManager.camera = GMSCameraPosition(
            target: newTarget,
            zoom: newZoom
        )
    }
}

struct MapButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}
