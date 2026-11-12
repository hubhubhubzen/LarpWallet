import SwiftUI

@main
struct FakeWalletApp: App {
    @StateObject private var store = WalletStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(TK.bg.ignoresSafeArea())
        }
    }
}
