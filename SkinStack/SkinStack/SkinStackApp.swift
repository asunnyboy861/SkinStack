import SwiftUI
import SwiftData

@main
struct SkinStackApp: App {
    let storeManager = StoreManager()
    let conflictEngine = ConflictDetectionEngine()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    ContentView()
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            .environment(storeManager)
            .environment(conflictEngine)
        }
        .modelContainer(for: [SkinProduct.self, SkinJournalEntry.self])
    }
}
