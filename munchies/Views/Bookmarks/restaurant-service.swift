import FirebaseFirestore
import Combine

class RestaurantService: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        setupOfflinePersistence()
    }
    
    private func setupOfflinePersistence() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    func startListening() {
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("restaurants")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else {
                    print("Error fetching restaurants: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self.restaurants = snapshot.documents.compactMap { Restaurant.from(document: $0) }
            }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
    }
    
    func updateRestaurant(_ restaurant: Restaurant) {
        do {
            try db.collection("restaurants").document(restaurant.id)
                .setData(restaurant.toFirestore(), merge: true)
        } catch {
            print("Error updating restaurant: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        db.collection("restaurants").document(restaurant.id)
            .updateData(["isFavorite": !restaurant.isFavorite])
    }
    
    func toggleWantToVisit(_ restaurant: Restaurant) {
        db.collection("restaurants").document(restaurant.id)
            .updateData(["wantToVisit": !restaurant.wantToVisit])
    }
}
