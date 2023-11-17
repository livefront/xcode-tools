import SwiftUI

@main
struct LivefrontDevToolsApp: App {

    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup("Livefront Developer Tools") {
            ContentView()
        }
    }
}
