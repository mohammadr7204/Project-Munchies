// Profile photo and name section
import SwiftUI

struct ProfileHeader: View {
    let user: User
    @State private var showingEditProfile = false
    
    var body: some View {
        VStack {
            // Profile Image
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .padding(.top)
            
            // User Info - Reordered to show full name first
            Text(user.fullName)  // Display full name first
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("@\(user.username)")  // Then show username
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Edit Profile Button
            Button(action: {
                showingEditProfile = true
            }) {
                Text("Edit Profile")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 32)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.top, 8)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
}
