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
    let type: String
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
    let placeId: String?
    var photoReferences: [String]?
    var priceLevel: Int?
    var phoneNumber: String?
    var website: String?
    var address: String?
    var openingHours: [String]?
    
    // Computed property
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, rating, distance, isOpen, imageUrl
        case latitude, longitude, isFavorite, wantToVisit, placeId
        case photoReferences, priceLevel, phoneNumber, website, address
        case openingHours
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
         openingHours: [String]? = nil) {
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
    }
    
    static func from(document: DocumentSnapshot) -> Restaurant? {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let location = data["location"] as? String,
              let isHalal = data["isHalal"] as? Bool,
              isHalal else { // Only process halal restaurants
            return nil
        }
        
        // Parse location string "[42.356005° N, 83.273794° W]"
        let coordinates = location.replacingOccurrences(of: "[", with: "")
                                .replacingOccurrences(of: "]", with: "")
                                .replacingOccurrences(of: "°", with: "")
                                .components(separatedBy: ",")
        
        guard coordinates.count == 2,
                  let latitudeStr = coordinates[0].trimmingCharacters(in: .whitespaces).components(separatedBy: " N").first,
                  let longitudeStr = coordinates[1].trimmingCharacters(in: .whitespaces).components(separatedBy: " W").first,
                  let latitude = Double(latitudeStr),
                  let longitude = Double(longitudeStr) else {
                print("Failed to parse location coordinates for document: \(document.documentID)")
                return nil
        }
        
        let cuisine = data["cuisine"] as? String ?? "Unspecified"
        let rating = data["rating"] as? Double ?? 0.0
        let phoneNumber = data["phoneNumber"] as? String
        let website = data["website"] as? String
        let address = data["address"] as? String
        let openingHours = data["openingHours"] as? [String]
        
        return Restaurant(
            id: document.documentID,
            name: name,
            type: cuisine,
            rating: rating,
            distance: 0,
            isOpen: true,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: -longitude),
            phoneNumber: data["phoneNumber"] as? String,
            website: data["website"] as? String,
            address: data["address"] as? String,
            openingHours: data["openingHours"] as? [String]
        )
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "name": name,
            "type": type,
            "rating": rating,
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
            "openingHours": openingHours as Any
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
