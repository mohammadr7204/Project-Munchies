import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var isExpanded: Bool
    let content: Content
    
    private let minHeight: CGFloat = 50
    private let tabBarHeight: CGFloat = 83 // Standard tab bar height
    private var maxHeight: CGFloat {
        UIScreen.main.bounds.height - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
    }
    
    @GestureState private var translation: CGFloat = 0
    
    init(isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    private var offset: CGFloat {
        isExpanded ? 0 : maxHeight - minHeight - tabBarHeight
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header and content same as before
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
                
                // Content
                content
            }
            .frame(height: maxHeight)
            .frame(maxWidth: .infinity)
            .background(
                Color(.systemBackground)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            )
            .offset(y: max(0, translation + offset))
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let snapDistance = maxHeight - minHeight - tabBarHeight
                        let dragPercentage = value.translation.height / snapDistance
                        
                        withAnimation(.interactiveSpring()) {
                            isExpanded = dragPercentage < 0.5
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
