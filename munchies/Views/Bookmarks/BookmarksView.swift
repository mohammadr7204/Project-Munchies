import SwiftUI
import FirebaseFirestore

@MainActor
class BookmarksViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    private let db = Firestore.firestore()
    
    func fetchBookmarkedRestaurants() {
        db.collection("hr")
            .whereFilter(Filter.orFilter([
                Filter.whereField("isFavorite", isEqualTo: true),
                Filter.whereField("wantToVisit", isEqualTo: true)
            ]))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching restaurants: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self.restaurants = documents.compactMap { Restaurant.from(document: $0) }
            }
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        db.collection("hr").document(restaurant.id)
            .updateData(["isFavorite": !restaurant.isFavorite])
    }
    
    func toggleWantToVisit(_ restaurant: Restaurant) {
        db.collection("hr").document(restaurant.id)
            .updateData(["wantToVisit": !restaurant.wantToVisit])
    }
}

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @State private var selectedCategory = "Favorites"
    let categories = ["Favorites", "Want to Visit"]
    
    var filteredRestaurants: [Restaurant] {
        switch selectedCategory {
        case "Favorites":
            return viewModel.restaurants.filter { $0.isFavorite }
        case "Want to Visit":
            return viewModel.restaurants.filter { $0.wantToVisit }
        default:
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                
                if filteredRestaurants.isEmpty {
                    EmptyBookmarksView(category: selectedCategory)
                } else {
                    List(filteredRestaurants) { restaurant in
                        RestaurantRow(
                            restaurant: restaurant,
                            onFavorite: { viewModel.toggleFavorite(restaurant) },
                            onWantToVisit: { viewModel.toggleWantToVisit(restaurant) }
                        )
                    }
                }
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
        .onAppear {
            viewModel.fetchBookmarkedRestaurants()
        }
    }
}

struct EmptyBookmarksView: View {
    let category: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category == "Favorites" ? "heart" : "bookmark")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No \(category) Yet")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
