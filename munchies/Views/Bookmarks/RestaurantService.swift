import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import CoreLocation
import Combine

// MARK: - Enrichment Extension
extension RestaurantService {
    func enrichRestaurant(_ restaurant: Restaurant) async -> Restaurant {
        // If there's no place ID, skip enrichment.
        guard let placeId = restaurant.placeId else {
            return restaurant
        }
        do {
            let place = try await GooglePlacesManager.shared.fetchPlaceDetails(for: placeId)
            var updatedRestaurant = restaurant
            
            updatedRestaurant.rating = Double(place.rating)
           
            if let _ = place.openingHours {
                updatedRestaurant.businessStatus = "Unknown" // Replace with custom logic if needed.
            }
            
            if let types = place.types, !types.isEmpty {
                updatedRestaurant.type = types.first ?? restaurant.type
            }
            
            return updatedRestaurant
        } catch {
            print("Error fetching place details for restaurant \(restaurant.name): \(error.localizedDescription)")
            return restaurant // Return original if enrichment fails.
        }
    }
    
    func enrichAllRestaurants() async {
        var enrichedRestaurants: [Restaurant] = []
        for restaurant in restaurants {
            let enriched = await enrichRestaurant(restaurant)
            enrichedRestaurants.append(enriched)
        }
        restaurants = enrichedRestaurants
    }
}

// MARK: - RestaurantService Class
@MainActor
class RestaurantService: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    
    private let db = Firestore.firestore()
    private let pageSize = 20
    private var lastDocument: DocumentSnapshot?
    private let locationManager: LocationManager
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func loadFirstPage() async throws {
        guard let userLocation = locationManager.location else { return }
        isLoading = true
        restaurants = []
        lastDocument = nil
        
        let center = userLocation.coordinate
        let radiusInMiles = 50.0
        let bounds = getBoundingBox(center: center, radiusInMiles: radiusInMiles)
        
        let snapshot = try await db.collection("hr")
            .whereField("latitude", isGreaterThan: bounds.minLat)
            .whereField("latitude", isLessThan: bounds.maxLat)
            .whereField("isHalal", isEqualTo: true)
            .getDocuments()
        
        processSnapshot(snapshot, userLocation: userLocation, radiusInMiles: radiusInMiles)
        isLoading = false
        
        // Enrich the restaurant data with details from Google Places.
        await enrichAllRestaurants()
        
    }
    
    func loadNextPage() async throws {
        guard let userLocation = locationManager.location,
              hasMoreData, !isLoading,
              let lastDocument = lastDocument else { return }
        
        isLoading = true
        
        let center = userLocation.coordinate
        let radiusInMiles = 50.0
        let bounds = getBoundingBox(center: center, radiusInMiles: radiusInMiles)
        
        let snapshot = try await db.collection("hr")
            .whereField("latitude", isGreaterThan: bounds.minLat)
            .whereField("latitude", isLessThan: bounds.maxLat)
            .whereField("isHalal", isEqualTo: true)
            .start(afterDocument: lastDocument)
            .getDocuments()
        
        processSnapshot(snapshot, userLocation: userLocation, radiusInMiles: radiusInMiles)
        isLoading = false
    }
    
    private func processSnapshot(_ snapshot: QuerySnapshot, userLocation: CLLocation, radiusInMiles: Double) {
        print("Documents found: \(snapshot.documents.count)")
        
        // Process documents into Restaurant models,
        // filtering by distance and sorting by distance.
        let nearbyRestaurants = snapshot.documents
            .compactMap { Restaurant.from(document: $0) }
            .filter { restaurant in
                let restaurantLocation = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
                let distance = userLocation.distance(from: restaurantLocation) / 1609.34
                return distance <= radiusInMiles
            }
            .sorted {
                let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
                let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
                return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
            }
            .prefix(pageSize)
        
        restaurants.append(contentsOf: nearbyRestaurants)
        lastDocument = snapshot.documents.last
        hasMoreData = nearbyRestaurants.count == pageSize
        
        print("Successfully parsed restaurants: \(nearbyRestaurants.count)")
    }
    
    private func getBoundingBox(center: CLLocationCoordinate2D, radiusInMiles: Double) -> (minLat: Double, maxLat: Double, minLng: Double, maxLng: Double) {
        let milesPerLatitude = 69.0
        let milesPerLongitude = cos(center.latitude * .pi / 180.0) * 69.0
        
        let latDelta = radiusInMiles / milesPerLatitude
        let lngDelta = radiusInMiles / milesPerLongitude
        
        return (
            minLat: center.latitude - latDelta,
            maxLat: center.latitude + latDelta,
            minLng: center.longitude - lngDelta,
            maxLng: center.longitude + lngDelta
        )
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        Task { @MainActor in
            let update: [String: Bool] = ["isFavorite": !restaurant.isFavorite]
            try? await db.collection("hr").document(restaurant.id).updateData(update)
        }
    }
    
    func toggleWantToVisit(_ restaurant: Restaurant) {
        Task { @MainActor in
            let update: [String: Bool] = ["wantToVisit": !restaurant.wantToVisit]
            try? await db.collection("hr").document(restaurant.id).updateData(update)
        }
    }
    
    func updateRestaurant(_ restaurant: Restaurant) {
        Task {
            do {
                try await db.collection("hr").document(restaurant.id)
                    .setData(restaurant.toFirestore(), merge: true)
            } catch {
                print("Error updating restaurant: \(error.localizedDescription)")
            }
        }
    }
}
