//Restaurant
import Foundation
import CoreLocation
import FirebaseFirestore

extension Restaurant: Equatable {
    static func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    var type: String  // Now mutable since we update it from Places
    var rating: Double
    var distance: Double
    var isOpen: Bool
    var imageUrl: String?
    var latitude: Double
    var longitude: Double
    
    // User preferences
    var isFavorite: Bool
    var wantToVisit: Bool
    
    // Google Places data
    var placeId: String?  // Added for Places integration
    var photoReferences: [String]?
    var priceLevel: Int?
    var phoneNumber: String?
    var website: String?
    var cuisineType: String?
    var address: String?
    var openingHours: [String]?
    var operatingStatus: String?  // Might remove this based off need case or not
    var businessStatus: String?  // Added to track operational status
    
    // Computed property
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, rating, distance, isOpen, imageUrl
        case latitude, longitude, isFavorite, wantToVisit, placeId
        case photoReferences, priceLevel, phoneNumber, website, address
        case openingHours, businessStatus
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         type: String,
         rating: Double = 0.0,
         distance: Double = 0.0,
         isOpen: Bool = true,
         imageUrl: String? = nil,
         coordinate: CLLocationCoordinate2D,
         isFavorite: Bool = false,
         wantToVisit: Bool = false,
         placeId: String? = nil,
         photoReferences: [String]? = nil,
         priceLevel: Int? = nil,
         phoneNumber: String? = nil,
         website: String? = nil,
         address: String? = nil,
         openingHours: [String]? = nil,
         businessStatus: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.rating = rating
        self.distance = distance
        self.isOpen = isOpen
        self.imageUrl = imageUrl
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.isFavorite = isFavorite
        self.wantToVisit = wantToVisit
        self.placeId = placeId
        self.photoReferences = photoReferences
        self.priceLevel = priceLevel
        self.phoneNumber = phoneNumber
        self.website = website
        self.address = address
        self.openingHours = openingHours
        self.businessStatus = businessStatus
    }
    
    static func from(document: DocumentSnapshot) -> Restaurant? {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let isHalal = data["isHalal"] as? Bool,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              isHalal else {
            return nil
        }
        
        return Restaurant(
            id: document.documentID,
            name: name,
            type: data["type"] as? String ?? "Unspecified",
            rating: data["rating"] as? Double ?? 0.0,
            distance: data["distance"] as? Double ?? 0.0,
            isOpen: data["isOpen"] as? Bool ?? true,
            imageUrl: data["imageUrl"] as? String,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            isFavorite: data["isFavorite"] as? Bool ?? false,
            wantToVisit: data["wantToVisit"] as? Bool ?? false,
            placeId: data["placeId"] as? String,
            photoReferences: data["photoReferences"] as? [String],
            priceLevel: data["priceLevel"] as? Int,
            phoneNumber: data["phoneNumber"] as? String,
            website: data["website"] as? String,
            address: data["address"] as? String,
            openingHours: data["openingHours"] as? [String],
            businessStatus: data["businessStatus"] as? String
        )
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "name": name,
            "type": type,
            "rating": rating,
            "distance": distance,
            "isOpen": isOpen,
            "imageUrl": imageUrl as Any,
            "latitude": latitude,
            "longitude": longitude,
            "isFavorite": isFavorite,
            "wantToVisit": wantToVisit,
            "placeId": placeId as Any,
            "photoReferences": photoReferences as Any,
            "priceLevel": priceLevel as Any,
            "phoneNumber": phoneNumber as Any,
            "website": website as Any,
            "address": address as Any,
            "openingHours": openingHours as Any,
            "businessStatus": businessStatus as Any
        ]
    }
}

enum RestaurantError: Error {
    case invalidData
    case invalidLocation
    case networkError
    case decodingError
    case documentNotFound
}
