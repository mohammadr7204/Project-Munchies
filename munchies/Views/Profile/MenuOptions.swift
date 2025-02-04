// Profile menu options list
import SwiftUI

struct MenuOptions: View {
    var body: some View {
        VStack(spacing: 16) {
            MenuOption(title: "My Reviews", icon: "star.fill")
            MenuOption(title: "Bookmarked Places", icon: "bookmark.fill")
            MenuOption(title: "Favorites", icon: "list.bullet")
            MenuOption(title: "Settings", icon: "gear")
            MenuOption(title: "Help & Feedback", icon: "questionmark.circle")
        }
        .padding()
    }
}

struct MenuOption: View {
    let title: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Add navigation action
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}
