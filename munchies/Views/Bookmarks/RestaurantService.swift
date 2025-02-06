import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import CoreLocation
import Combine

// MARK: - Cache Structures
private struct CachedData {
    let restaurants: [Restaurant]
    let timestamp: Date
}

private struct QuadrantKey: Hashable {
    let latitude: Double
    let longitude: Double
    
    var stringValue: String {
        "\(latitude),\(longitude)"
    }
}

@MainActor
class RestaurantService: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var hasMoreData = true
    @Published var visibleRegion: GMSVisibleRegion?
    
    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    // Cache settings
    private var cache: [QuadrantKey: CachedData] = [:]
    private let cacheExpiration: TimeInterval = 1800 // 30 minutes
    private let maxResults = 100
    private var currentResultCount = 0
    private var loadedRestaurantIds = Set<String>()
    private var lastQueriedRegion: GMSVisibleRegion?
    private let queryOverlapThreshold = 0.7
    
    // MARK: - Initialization
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    // MARK: - Public Methods
    func loadRestaurantsInView() async throws {
        guard let region = visibleRegion,
              shouldRefetchRegion(region) else {
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Check cache first
        if let cachedRestaurants = getCachedRestaurants(for: region) {
            appendNewRestaurants(cachedRestaurants)
            return
        }
        
        // If we've hit our limit, don't load more
        guard currentResultCount < maxResults else {
            hasMoreData = false
            return
        }
        
        let bounds = getBoundingBox(from: region)
        let newRestaurants = try await fetchRestaurantsInBatches(bounds: bounds)
        
        // Cache the results
        cacheRestaurants(newRestaurants, for: region)
        
        // Update the UI
        appendNewRestaurants(newRestaurants)
        
        // Update tracking
        lastQueriedRegion = region
        currentResultCount += newRestaurants.count
        hasMoreData = newRestaurants.count >= 20 // Assuming batch size of 20
    }
    
    func clearCache() {
        cache.removeAll()
        loadedRestaurantIds.removeAll()
        currentResultCount = 0
        lastQueriedRegion = nil
        hasMoreData = true
    }
    
    // MARK: - Private Methods
    private func shouldRefetchRegion(_ newRegion: GMSVisibleRegion) -> Bool {
        guard let lastRegion = lastQueriedRegion else { return true }
        return calculateOverlap(lastRegion, newRegion) < queryOverlapThreshold
    }
    
    private func calculateOverlap(_ region1: GMSVisibleRegion, _ region2: GMSVisibleRegion) -> Double {
        // Simplified overlap calculation
        let r1MinLat = min(region1.nearLeft.latitude, region1.farLeft.latitude)
        let r1MaxLat = max(region1.nearRight.latitude, region1.farRight.latitude)
        let r2MinLat = min(region2.nearLeft.latitude, region2.farLeft.latitude)
        let r2MaxLat = max(region2.nearRight.latitude, region2.farRight.latitude)
        
        let latOverlap = max(0, min(r1MaxLat, r2MaxLat) - max(r1MinLat, r2MinLat))
        let latTotal = max(r1MaxLat, r2MaxLat) - min(r1MinLat, r2MinLat)
        
        return latOverlap / latTotal
    }
    
    private func getQuadrantKey(_ coordinate: CLLocationCoordinate2D) -> QuadrantKey {
        let lat = floor(coordinate.latitude * 10) / 10
        let lng = floor(coordinate.longitude * 10) / 10
        return QuadrantKey(latitude: lat, longitude: lng)
    }
    
    private func getCachedRestaurants(for region: GMSVisibleRegion) -> [Restaurant]? {
        let key = getQuadrantKey(region.nearLeft)
        guard let cachedData = cache[key],
              Date().timeIntervalSince(cachedData.timestamp) < cacheExpiration else {
            return nil
        }
        return cachedData.restaurants
    }
    
    private func cacheRestaurants(_ restaurants: [Restaurant], for region: GMSVisibleRegion) {
        let key = getQuadrantKey(region.nearLeft)
        cache[key] = CachedData(restaurants: restaurants, timestamp: Date())
    }
    
    private func fetchRestaurantsInBatches(bounds: (minLat: Double, maxLat: Double, minLng: Double, maxLng: Double)) async throws -> [Restaurant] {
        let batchSize = 5
        let latStep = (bounds.maxLat - bounds.minLat) / Double(batchSize)
        var allRestaurants: [Restaurant] = []
        
        for i in 0..<batchSize {
            let batchMinLat = bounds.minLat + (latStep * Double(i))
            let batchMaxLat = batchMinLat + latStep
            
            let query = db.collection("hr")
                .whereField("latitude", isGreaterThan: batchMinLat)
                .whereField("latitude", isLessThan: batchMaxLat)
                .whereField("isHalal", isEqualTo: true)
                .limit(to: 20)
            
            let snapshot = try await query.getDocuments()
            let batchRestaurants = snapshot.documents
                .compactMap { Restaurant.from(document: $0) }
                .filter { restaurant in
                    !loadedRestaurantIds.contains(restaurant.id) &&
                    restaurant.longitude >= bounds.minLng &&
                    restaurant.longitude <= bounds.maxLng
                }
            
            allRestaurants.append(contentsOf: batchRestaurants)
            
            // Track loaded restaurant IDs
            batchRestaurants.forEach { restaurant in
                loadedRestaurantIds.insert(restaurant.id)
            }
        }
        
        return allRestaurants
    }
    
    private func appendNewRestaurants(_ newRestaurants: [Restaurant]) {
        // Sort by distance if user location is available
        if let userLocation = locationManager.location {
            let sortedRestaurants = newRestaurants.sorted { restaurant1, restaurant2 in
                let location1 = CLLocation(latitude: restaurant1.latitude, longitude: restaurant1.longitude)
                let location2 = CLLocation(latitude: restaurant2.latitude, longitude: restaurant2.longitude)
                return userLocation.distance(from: location1) < userLocation.distance(from: location2)
            }
            restaurants.append(contentsOf: sortedRestaurants)
        } else {
            restaurants.append(contentsOf: newRestaurants)
        }
    }
    
    private func getBoundingBox(from region: GMSVisibleRegion) -> (minLat: Double, maxLat: Double, minLng: Double, maxLng: Double) {
        let latitudes = [region.nearLeft.latitude, region.nearRight.latitude,
                        region.farLeft.latitude, region.farRight.latitude]
        let longitudes = [region.nearLeft.longitude, region.nearRight.longitude,
                         region.farLeft.longitude, region.farRight.longitude]
        
        return (
            minLat: latitudes.min() ?? -90,
            maxLat: latitudes.max() ?? 90,
            minLng: longitudes.min() ?? -180,
            maxLng: longitudes.max() ?? 180
        )
    }
    
    // MARK: - Restaurant Actions
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

// MARK: - Enrichment Extension
extension RestaurantService {
    func enrichRestaurant(_ restaurant: Restaurant) async -> Restaurant {
        guard let placeId = restaurant.placeId else {
            return restaurant
        }
        do {
            let place = try await GooglePlacesManager.shared.fetchPlaceDetails(for: placeId)
            var updatedRestaurant = restaurant
            
            updatedRestaurant.rating = Double(place.rating)
            
            if let types = place.types, !types.isEmpty {
                updatedRestaurant.type = types.first ?? restaurant.type
            }
            
            return updatedRestaurant
        } catch {
            print("Error fetching place details for restaurant \(restaurant.name): \(error.localizedDescription)")
            return restaurant
        }
    }
}
