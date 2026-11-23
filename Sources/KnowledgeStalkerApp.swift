import SwiftUI
import SwiftData

@main
struct KnowledgeStalkerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [PlayerProfile.self, CompletedQuest.self])
    }
}
