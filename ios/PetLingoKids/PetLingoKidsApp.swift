import SwiftUI

@main
struct PetLingoKidsApp: App {
    @StateObject private var speech = SpeechService()
    @StateObject private var progress = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(speech)
                .environmentObject(progress)
        }
    }
}
