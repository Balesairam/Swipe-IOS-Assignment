import SwiftUI

@main
struct SwipeTaskApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    ProductListView(refreshProducts: true)
                }
            }
        }
    }
}
