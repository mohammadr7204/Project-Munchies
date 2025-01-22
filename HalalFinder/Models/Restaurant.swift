import SwiftUI
import MapKit

struct Restaurant: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let rating: Double
    let distance: Double
    let isOpen: Bool
    let imageUrl: String?
    let coordinate: CLLocationCoordinate2D
    
    // Sample data with coordinates
    static let sampleData = [
        Restaurant(
            name: "Halal Guys",
            type: "Middle Eastern",
            rating: 4.5,
            distance: 0.8,
            isOpen: true,
            imageUrl: nil,
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ),
        Restaurant(
            name: "Mediterranean Cuisine",
            type: "Mediterranean",
            rating: 4.2,
            distance: 1.2,
            isOpen: true,
            imageUrl: nil,
            coordinate: CLLocationCoordinate2D(latitude: 37.7829, longitude: -122.4324)
        ),
        Restaurant(
            name: "Istanbul Kebab",
            type: "Turkish",
            rating: 4.7,
            distance: 1.5,
            isOpen: true,
            imageUrl: nil,
            coordinate: CLLocationCoordinate2D(latitude: 37.7699, longitude: -122.4148)
        ),
        Restaurant(
            name: "Shawarma House",
            type: "Middle Eastern",
            rating: 4.3,
            distance: 1.8,
            isOpen: false,
            imageUrl: nil,
            coordinate: CLLocationCoordinate2D(latitude: 37.7879, longitude: -122.4074)
        ),
        Restaurant(
            name: "Falafel King",
            type: "Middle Eastern",
            rating: 4.1,
            distance: 2.0,
            isOpen: true,
            imageUrl: nil,
            coordinate: CLLocationCoordinate2D(latitude: 37.7819, longitude: -122.4144)
        )
    ]
}
