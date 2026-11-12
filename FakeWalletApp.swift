import SwiftUI

@main
struct FakeWalletApp: App {
    @StateObject private var store = WalletStore()

    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                ContentView()
                    .padding(.top, proxy.safeAreaInsets.top)
                    .padding(.bottom, proxy.safeAreaInsets.bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(TK.bg)
                    .ignoresSafeArea(.all)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(TK.bg.ignoresSafeArea())
            .environmentObject(store)
            .preferredColorScheme(.dark)
        }
    }
}
