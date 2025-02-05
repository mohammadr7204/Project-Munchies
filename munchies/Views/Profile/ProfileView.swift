// Main profile view
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
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
        .navigationBarTitle("Profile", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    authManager.signOut()
                }
            }
        }
    }
}
