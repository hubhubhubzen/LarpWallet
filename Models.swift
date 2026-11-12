import Foundation

struct FakeToken: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var symbol: String
    var balance: Double
    var usdPrice: Double
    var iconColorHex: String

    var usdValue: Double { balance * usdPrice }
}

struct FakeTx: Identifiable, Codable {
    var id = UUID()
    var tokenSymbol: String
    var amount: Double
    var toAddress: String
    var date: Date
    var outgoing: Bool
}
