// Main profile view
import SwiftUI

struct ProfileView: View {
    @State private var user = User(
        id: "1",
        username: "foodie123",
        fullName: "John Doe",
        email: "john@example.com",
        profileImageUrl: nil,
        bookmarkedRestaurants: [],
        wantToVisit: [],
        reviewCount: 0,
        preferences: ["Halal", "Middle Eastern"]
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ProfileHeader(user: user)
                StatsView(user: user)
                MenuOptions()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preferences")
                        .font(.headline)
                    
                    ForEach(user.preferences, id: \.self) { preference in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(preference)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
