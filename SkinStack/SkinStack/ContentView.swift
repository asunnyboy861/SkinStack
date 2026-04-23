import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SkinProduct.addedDate) private var products: [SkinProduct]
    @Environment(StoreManager.self) private var storeManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RoutineView()
                .tabItem {
                    Label("Routine", systemImage: "sun.and.horizon")
                }
                .tag(0)
            
            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "bottle.fill")
                }
                .tag(1)
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color.skinStackPrimary)
        .onAppear {
            if products.count > 3 && !storeManager.isPro {
                selectedTab = 1
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self], inMemory: true)
        .environment(StoreManager())
        .environment(ConflictDetectionEngine())
}
