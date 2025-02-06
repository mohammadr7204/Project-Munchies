// Stats section
import SwiftUI

struct StatsView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 40) {
            StatItem(title: "Bookmarked", count: user.bookmarkedRestaurants.count)
            StatItem(title: "Visited", count: user.wantToVisit.count)
            StatItem(title: "Reviews", count: user.reviewCount)
        }
        .padding()
    }
}

struct StatItem: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}
