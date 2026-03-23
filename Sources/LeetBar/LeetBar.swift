import SwiftUI

@main
struct LeetBarApp: App {
    var body: some Scene {
        MenuBarExtra("LeetBar", systemImage: "chart.bar.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
