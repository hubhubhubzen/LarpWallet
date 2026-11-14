import SwiftUI

@main
struct FakeWalletApp: App {
    @StateObject private var store = WalletStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                TK.bg.ignoresSafeArea()
                ContentView()
            }
            .environmentObject(store)
            .preferredColorScheme(.dark)
        }
    }
}
