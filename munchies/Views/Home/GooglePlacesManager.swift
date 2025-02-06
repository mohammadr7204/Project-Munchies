// GOOGLEPLACESMANAGER
import Foundation
import GooglePlaces

class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    private init() { }

    func fetchPlaceDetails(for placeId: String) async throws -> GMSPlace {
        try await withCheckedThrowingContinuation { continuation in
            // Replace .geometry with .coordinate
            let fields: GMSPlaceField = [.name, .rating, .openingHours, .types, .coordinate, .phoneNumber, .website]
            GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil) { place, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let place = place {
                    continuation.resume(returning: place)
                } else {
                    let error = NSError(domain: "GooglePlaces", code: -1, userInfo: [NSLocalizedDescriptionKey: "Place not found"])
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

