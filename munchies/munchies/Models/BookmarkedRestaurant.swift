//
//  BookmarkedRestaurant.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/23/25.
//

import Foundation

struct BookmarkedRestaurant: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let imageUrl: String
    let cuisine: String
    let rating: Double
    var isFavorite: Bool
    var wantToVisit: Bool
    
    // Optional additional details
    let phoneNumber: String?
    let website: String?
    let hours: [String: String]?
    
    // Computed property for formatted rating
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
}
