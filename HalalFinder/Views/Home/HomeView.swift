import SwiftUI
import MapKit

struct HomeView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var isBottomSheetExpanded = false
    
    var body: some View {
        ZStack {
            // Map View
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)
            
            // Search Bar at top
            VStack {
                SearchBar()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Spacer()
            }
            
            // Bottom Sheet
            VStack {
                Spacer()
                BottomSheet(isExpanded: $isBottomSheetExpanded) {
                    RestaurantList()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
