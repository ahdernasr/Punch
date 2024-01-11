import SwiftUI

@main
struct PunchApp: App {
    @State private var isFirstLaunch: Bool

    init() {
        _isFirstLaunch = State(initialValue: !UserDefaults.standard.bool(forKey: "hasLaunchedBefore"))
    }

    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                FirstLaunchView()
            } else {
                ContentView()
            }
        }
    }
}
