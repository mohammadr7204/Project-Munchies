//
//  RestaurantRow.swift
//  munchies
//
//  Created by Mohammad Rahim on 1/23/25.
//

import SwiftUI

struct RestaurantRow: View {
    let restaurant: BookmarkedRestaurant
    var onFavorite: () -> Void
    var onWantToVisit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Restaurant Image
                AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                
                // Restaurant Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.headline)
                    
                    Text(restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(restaurant.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(restaurant.formattedRating)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Bookmark Actions
                VStack(spacing: 12) {
                    Button(action: onFavorite) {
                        Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(restaurant.isFavorite ? .red : .gray)
                    }
                    
                    Button(action: onWantToVisit) {
                        Image(systemName: restaurant.wantToVisit ? "bookmark.fill" : "bookmark")
                            .foregroundColor(restaurant.wantToVisit ? .blue : .gray)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
