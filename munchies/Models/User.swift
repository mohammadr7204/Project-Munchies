//
//  User.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/23/25.
//
import Foundation

struct User: Identifiable {
    let id: String
    var username: String
    var firstName: String
    var lastName: String
    var birthday: Date
    var email: String
    var profileImageUrl: String?
    var bookmarkedRestaurants: [String]
    var wantToVisit: [String]
    var reviewCount: Int
    var preferences: [String]
    var fullName: String {
            "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        }
}
