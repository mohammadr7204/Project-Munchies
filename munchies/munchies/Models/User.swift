//
//  User.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/23/25.
//

struct User: Identifiable {
    let id: String
    var username: String
    var fullName: String
    var email: String
    var profileImageUrl: String?
    var bookmarkedRestaurants: [String] // Restaurant IDs
    var wantToVisit: [String] // Restaurant IDs
    var reviewCount: Int
    var preferences: [String] // Cuisine preferences, dietary restrictions
}
