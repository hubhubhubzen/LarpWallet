import SwiftUI
import UIKit

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
                .onAppear {
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap(\.windows)
                        .forEach { $0.backgroundColor = TK.uiColor }
                }
        }
    }
}
