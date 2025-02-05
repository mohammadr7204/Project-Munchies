//RestaurantServices
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import CoreLocation
import Combine

@MainActor
class RestaurantService: ObservableObject {
    @Published private(set) var restaurants: [Restaurant] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreData = true
    
    private let db = Firestore.firestore()
    private let pageSize = 20
    private var lastDocument: DocumentSnapshot?
    
    func loadFirstPage() async throws {
        isLoading = true
        restaurants = []
        lastDocument = nil
        
        let snapshot = try await db.collection("hr")
            .whereField("isHalal", isEqualTo: true)
            .order(by: "name")
            .limit(to: pageSize)
            .getDocuments()
        
        processSnapshot(snapshot)
        isLoading = false
    }
    
    func loadNextPage() async throws {
        guard hasMoreData, !isLoading, let lastDocument = lastDocument else { return }
        
        isLoading = true
        
        let snapshot = try await db.collection("hr")
            .whereField("isHalal", isEqualTo: true)
            .order(by: "name")
            .limit(to: pageSize)
            .start(afterDocument: lastDocument)
            .getDocuments()
        
        processSnapshot(snapshot)
        isLoading = false
    }
    
    private func processSnapshot(_ snapshot: QuerySnapshot) {
        let newRestaurants = snapshot.documents.compactMap { Restaurant.from(document: $0) }
        restaurants.append(contentsOf: newRestaurants)
        
        lastDocument = snapshot.documents.last
        hasMoreData = newRestaurants.count == pageSize
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        Task {
                    try? await db.collection("hr").document(restaurant.id)
                        .updateData(["isFavorite": !restaurant.isFavorite])
                }
            }
    
    func toggleWantToVisit(_ restaurant: Restaurant) {
        Task {
                    try? await db.collection("hr").document(restaurant.id)
                        .updateData(["wantToVisit": !restaurant.wantToVisit])
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
