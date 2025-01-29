// Main bookmarks view
import SwiftUI

struct BookmarksView: View {
    @State private var selectedCategory = "Favorites"
    let categories = ["Favorites", "Want to Visit"]
    
    // Sample data - you'll replace this with real data later
    let sampleRestaurants = [
        BookmarkedRestaurant(
            id: "1",
            name: "Halal Guys",
            address: "340 O'Farrell St, San Francisco, CA 94102",
            imageUrl: "sample-image-url",
            cuisine: "Middle Eastern",
            rating: 4.5,
            isFavorite: true,
            wantToVisit: false,
            phoneNumber: "(415) 549-3454",
            website: "thehalalguys.com",
            hours: ["Monday": "10AM-2AM", "Tuesday": "10AM-2AM", "Wednesday": "10AM-2AM"]
        ),
        BookmarkedRestaurant(
            id: "2",
            name: "Old Jerusalem",
            address: "2976 Mission St, San Francisco, CA 94110",
            imageUrl: "sample-image-url",
            cuisine: "Mediterranean",
            rating: 4.7,
            isFavorite: true,
            wantToVisit: false,
            phoneNumber: "(415) 642-5958",
            website: "oldjerusalemrestaurant.com",
            hours: ["Monday": "11AM-9PM", "Tuesday": "11AM-9PM", "Wednesday": "11AM-9PM"]
        ),
        BookmarkedRestaurant(
            id: "3",
            name: "Shalimar",
            address: "532 Jones St, San Francisco, CA 94102",
            imageUrl: "sample-image-url",
            cuisine: "Indian/Pakistani",
            rating: 4.2,
            isFavorite: false,
            wantToVisit: true,
            phoneNumber: "(415) 928-0333",
            website: "shalimarsf.com",
            hours: ["Monday": "11AM-11PM", "Tuesday": "11AM-11PM", "Wednesday": "11AM-11PM"]
        ),
        BookmarkedRestaurant(
            id: "4",
            name: "Z & Y Restaurant",
            address: "655 Jackson St, San Francisco, CA 94133",
            imageUrl: "sample-image-url",
            cuisine: "Chinese Halal",
            rating: 4.4,
            isFavorite: false,
            wantToVisit: true,
            phoneNumber: "(415) 981-8988",
            website: "zandyrestaurant.com",
            hours: ["Monday": "11:30AM-9:30PM", "Tuesday": "11:30AM-9:30PM"]
        ),
        BookmarkedRestaurant(
            id: "5",
            name: "Truly Mediterranean",
            address: "3109 16th St, San Francisco, CA 94103",
            imageUrl: "sample-image-url",
            cuisine: "Mediterranean",
            rating: 4.6,
            isFavorite: true,
            wantToVisit: false,
            phoneNumber: "(415) 252-7482",
            website: nil,
            hours: ["Monday": "11AM-10PM", "Tuesday": "11AM-10PM"]
        )
    ]
    
    var filteredRestaurants: [BookmarkedRestaurant] {
            switch selectedCategory {
            case "Favorites":
                return sampleRestaurants.filter { $0.isFavorite }
            case "Want to Visit":
                return sampleRestaurants.filter { $0.wantToVisit }
            default:
                return []
            }
        }
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Category selector
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(
                                title: category,
                                isSelected: category == selectedCategory,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Restaurant list with filtered restaurants
                    BookmarksList(restaurants: filteredRestaurants)
                        .padding(.top, 16)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Bookmarks")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
