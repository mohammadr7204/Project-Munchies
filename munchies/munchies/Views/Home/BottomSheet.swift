import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: Content
    
    private let minHeight: CGFloat = 60
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7 // Reduced to show search bar
    
    @GestureState private var translation: CGFloat = 0
    
    init(isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 4) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    // Title
                    HStack {
                        Text("Nearby Restaurants")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Content
                if isExpanded {
                    content
                        .transition(.opacity)
                }
            }
            .frame(height: currentHeight)
            .frame(maxWidth: .infinity)
            .background(
                Color(.systemBackground)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            )
            .offset(y: max(0, translation + currentOffset(geometry)))
            .animation(.interactiveSpring(), value: isExpanded)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let snapDistance = maxHeight - minHeight
                        let dragPercentage = value.translation.height / snapDistance
                        
                        withAnimation(.interactiveSpring()) {
                            if dragPercentage >= 0.5 {
                                isExpanded = false
                            } else if dragPercentage <= -0.5 {
                                isExpanded = true
                            } else {
                                isExpanded.toggle()
                            }
                        }
                    }
            )
        }
    }
    
    private var currentHeight: CGFloat {
        isExpanded ? maxHeight : minHeight
    }
    
    private func currentOffset(_ geometry: GeometryProxy) -> CGFloat {
        let totalHeight = geometry.size.height
        let targetHeight = isExpanded ? maxHeight : minHeight
        return totalHeight - targetHeight
    }
}
// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct BottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            BottomSheet(isExpanded: .constant(true)) {
                VStack {
                    Text("Restaurant List")
                        .font(.headline)
                        .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            ForEach(0..<10, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 80)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
            }
        }
    }
}
