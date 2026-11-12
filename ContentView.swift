import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var store: WalletStore
    @State private var showSettings = false
    @State private var showSend = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // ── top bar ─────────────────────────
                    HStack {
                        Text("Wallet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)

                    // ── total balance ───────────────────
                    VStack(spacing: 6) {
                        Text("Total Balance")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(String(format: "$%.2f", store.totalUSD))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                    }
                    .padding(.top, 10)

                    // ── address ─────────────────────────
                    HStack(spacing: 8) {
                        Image(systemName: "wallet.pass")
                            .foregroundColor(Color(hex: "0098EA"))
                        Text(shortAddress(store.address))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                        Button {
                            UIPasteboard.general.string = store.address
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())

                    // ── action buttons ──────────────────
                    HStack(spacing: 14) {
                        ActionButton(title: "Send",
                                     icon: "arrow.up.right",
                                     color: Color(hex: "0098EA")) {
                            showSend = true
                        }
                        ActionButton(title: "Receive",
                                     icon: "arrow.down.left",
                                     color: Color(hex: "26A17B")) {}
                        ActionButton(title: "Scan",
                                     icon: "qrcode.viewfinder",
                                     color: Color(hex: "8B5CF6")) {}
                    }
                    .padding(.horizontal)

                    // ── token list ──────────────────────
                    VStack(spacing: 0) {
                        ForEach(store.tokens) { token in
                            TokenRow(token: token)
                            if token.id != store.tokens.last?.id {
                                Divider().background(Color.white.opacity(0.06))
                            }
                        }
                    }
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal)

                    // ── history (last 5) ────────────────
                    if !store.history.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            ForEach(store.history.prefix(5)) { tx in
                                HStack {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                        .foregroundColor(.red)
                                    VStack(alignment: .leading) {
                                        Text("Sent \(tx.amount, specifier: "%.2f") \(tx.tokenSymbol)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                        Text(shortAddress(tx.toAddress))
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(tx.date, style: .time)
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 4)
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showSend) {
            SendView()
                .environmentObject(store)
        }
    }

    private func shortAddress(_ a: String) -> String {
        guard a.count > 12 else { return a }
        return "\(a.prefix(6))...\(a.suffix(6))"
    }
}

// ── reusable ──────────────────────────────────────────────
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(color)
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TokenRow: View {
    let token: FakeToken

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: token.iconColorHex))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(token.symbol.prefix(1))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(token.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(token.symbol)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(token.balance, specifier: token.balance > 10000 ? "%.0f" : "%.2f")")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(String(format: "$%.2f", token.usdValue))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ── Color(hex:) helper ────────────────────────────────────
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)
        let r, g, b: UInt64
        switch h.count {
        case 6:
            r = (v >> 16) & 0xFF; g = (v >> 8) & 0xFF; b = v & 0xFF
        default:
            r = 0; g = 0; b = 0
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: 1)
    }
}
