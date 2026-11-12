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

    private let key = "tonkeeper_fake_state_v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.address = saved.address
            self.tokens = saved.tokens
            self.history = saved.history
        } else {
            self.address = "UQBFakeAddress_000000000000000000000000000"
            self.tokens = [
                FakeToken(name: "Toncoin", symbol: "TON",
                          balance: 1240.50, usdPrice: 5.42,
                          iconColorHex: "0098EA"),
                FakeToken(name: "Tether USD", symbol: "USDT",
                          balance: 3200.00, usdPrice: 1.00,
                          iconColorHex: "26A17B"),
                FakeToken(name: "Notcoin", symbol: "NOT",
                          balance: 150000, usdPrice: 0.008,
                          iconColorHex: "000000")
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
