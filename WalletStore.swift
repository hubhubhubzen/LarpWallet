import Foundation
import SwiftUI

final class WalletStore: ObservableObject {
    @Published var address: String {
        didSet { save() }
    }
    @Published var tokens: [FakeToken] {
        didSet { save() }
    }
    @Published var history: [FakeTx] {
        didSet { save() }
    }

    static let storageKey = "tonkeeper_fake_state_v3"
    private let key = WalletStore.storageKey

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.address = saved.address
            self.tokens = saved.tokens
            self.history = saved.history
        } else {
            self.address = "UQDu0000000000000000000000003CZI"
            self.tokens = [
                FakeToken(name: "Ethereum", symbol: "ETH",
                          balance: 0, usdPrice: 1849.48,
                          iconColorHex: "627EEA", priceChange: -5.48),
                FakeToken(name: "BNB", symbol: "BNB",
                          balance: 0, usdPrice: 598.54,
                          iconColorHex: "F0B90B", priceChange: -6.49),
                FakeToken(name: "Solana", symbol: "SOL",
                          balance: 0, usdPrice: 73.93,
                          iconColorHex: "07080A", priceChange: -9.02),
                FakeToken(name: "Tether USD", symbol: "USDT",
                          balance: 0, usdPrice: 0.999,
                          iconColorHex: "26A17B", priceChange: 0.02, network: "TRON"),
                FakeToken(name: "USD Coin", symbol: "USDC",
                          balance: 0, usdPrice: 0.999,
                          iconColorHex: "2775CA", priceChange: 0, network: "ARBITRUM")
            ]
            self.history = []
        }
    }

    var totalUSD: Double {
        tokens.reduce(0) { $0 + $1.usdValue }
    }

    func updateBalance(tokenID: UUID, newBalance: Double) {
        guard let i = tokens.firstIndex(where: { $0.id == tokenID }) else { return }
        tokens[i].balance = newBalance
    }

    func addToken(_ token: FakeToken) {
        tokens.append(token)
    }

    func deleteToken(_ token: FakeToken) {
        tokens.removeAll { $0.id == token.id }
    }

    func send(symbol: String, amount: Double, to: String) {
        guard let i = tokens.firstIndex(where: { $0.symbol == symbol }) else { return }
        guard tokens[i].balance >= amount else { return }
        tokens[i].balance -= amount
        history.insert(FakeTx(tokenSymbol: symbol, amount: amount,
                              toAddress: to, date: Date(), outgoing: true),
                       at: 0)
    }

    private func save() {
        let state = SavedState(address: address, tokens: tokens, history: history)
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private struct SavedState: Codable {
        var address: String
        var tokens: [FakeToken]
        var history: [FakeTx]
    }
}
