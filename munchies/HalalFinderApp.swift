// Main app entry point
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleMaps
import GooglePlaces


@main
struct MunchiesApp: App {
    @StateObject private var authManager = AuthManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
        var body: some Scene {
            WindowGroup {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
        }
    }

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        
        // Set up Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        // Configure Google Maps
        GMSServices.provideAPIKey("AIzaSyD8DIkxp1_v3YkEty1R1spWj0EV323Svto")
        GMSPlacesClient.provideAPIKey("AIzaSyD8DIkxp1_v3YkEty1R1spWj0EV323Svto")
        return true
    }
}
