import SwiftUI
import UIKit

enum TK {
    static let bg = Color(hex: "10161F")
    static let card = Color(hex: "1D2633")
    static let button = Color(hex: "2E3847")
    static let accent = Color(hex: "45AEF5")
    static let secondary = Color(hex: "8994A3")
    static let green = Color(hex: "39CC83")
    static let red = Color(hex: "FF4766")
}

enum AppTab: Hashable {
    case wallet, activity, browser, collectibles
}

struct ContentView: View {
    @EnvironmentObject var store: WalletStore
    @State private var tab: AppTab = .wallet
    @State private var showSettings = false
    @State private var showSend = false
    @State private var showReceive = false
    @State private var notice: Notice?

    var body: some View {
        ZStack {
            TK.bg.ignoresSafeArea()

            Group {
                switch tab {
                case .wallet:
                    WalletHome(
                        showSettings: $showSettings,
                        showSend: $showSend,
                        showReceive: $showReceive,
                        notice: $notice
                    )
                case .activity:
                    ActivityView()
                case .browser:
                    PlaceholderTab(
                        icon: "safari",
                        title: "Browser",
                        message: "Explore apps and services on TON."
                    )
                case .collectibles:
                    PlaceholderTab(
                        icon: "square.grid.2x2",
                        title: "Collectibles",
                        message: "NFTs and collectibles will show up here."
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            TKTabBar(tab: $tab)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(store)
        }
        .sheet(isPresented: $showSend) {
            SendView().environmentObject(store)
        }
        .sheet(isPresented: $showReceive) {
            ReceiveView().environmentObject(store)
        }
        .sheet(item: $notice) { notice in
            PlaceholderSheet(title: notice.title)
        }
    }
}

struct WalletHome: View {
    @EnvironmentObject var store: WalletStore
    @Binding var showSettings: Bool
    @Binding var showSend: Bool
    @Binding var showReceive: Bool
    @Binding var notice: Notice?
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button {
                        showSettings = true
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(TK.accent)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "diamond.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            Text("Wallet")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(TK.secondary)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        notice = Notice(title: "Scan")
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                VStack(spacing: 8) {
                    Text(tkUSD(store.totalUSD))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    Button {
                        UIPasteboard.general.string = store.address
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            copied = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(copied ? "Copied" : shortAddress(store.address))
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(TK.secondary)
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 26)

                HStack(spacing: 0) {
                    TKAction(title: "Send", icon: "arrow.up") { showSend = true }
                    TKAction(title: "Receive", icon: "arrow.down") { showReceive = true }
                    TKAction(title: "Scan", icon: "qrcode") { notice = Notice(title: "Scan") }
                    TKAction(title: "Swap", icon: "arrow.left.arrow.right") { notice = Notice(title: "Swap") }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 28)

                VStack(spacing: 0) {
                    ForEach(store.tokens) { token in
                        TokenRow(token: token)
                        if token.id != store.tokens.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.06))
                                .padding(.leading, 72)
                        }
                    }
                }
                .background(TK.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 16)
        }
    }
}

struct ActivityView: View {
    @EnvironmentObject var store: WalletStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Activity")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)

            if store.history.isEmpty {
                Spacer()
                PlaceholderTab(
                    icon: "clock",
                    title: "No transactions",
                    message: "Sent transfers will appear here."
                )
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(store.history) { tx in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(TK.button)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(TK.red)
                                    )
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Sent")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(shortAddress(tx.toAddress))
                                        .font(.system(size: 13))
                                        .foregroundColor(TK.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text("−\(tkAmount(tx.amount)) \(tx.tokenSymbol)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(TK.red)
                                    Text(tx.date, style: .time)
                                        .font(.system(size: 13))
                                        .foregroundColor(TK.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct PlaceholderTab: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(TK.secondary)
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(TK.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        NavigationStack {
            ZStack {
                TK.bg.ignoresSafeArea()
                PlaceholderTab(
                    icon: title == "Scan" ? "qrcode.viewfinder" : "arrow.left.arrow.right",
                    title: title,
                    message: title == "Scan"
                        ? "Point the camera at a QR code."
                        : "Token swaps are not available."
                )
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
}

struct ReceiveView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ZStack {
                TK.bg.ignoresSafeArea()
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white)
                        .frame(width: 180, height: 180)
                        .overlay(
                            Image(systemName: "qrcode")
                                .font(.system(size: 120, weight: .regular))
                                .foregroundColor(.black)
                        )
                    Text(store.address)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                    Button {
                        UIPasteboard.general.string = store.address
                        copied = true
                    } label: {
                        Text(copied ? "Copied" : "Copy address")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(TK.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                }
                .padding(.top, 28)
            }
            .navigationTitle("Receive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct TKTabBar: View {
    @Binding var tab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
            HStack {
                tabItem(.wallet, "wallet.pass.fill", "Wallet")
                tabItem(.activity, "clock.fill", "Activity")
                tabItem(.browser, "safari.fill", "Browser")
                tabItem(.collectibles, "square.grid.2x2.fill", "Collectibles")
            }
            .padding(.top, 8)
            .padding(.bottom, 2)
        }
        .background(TK.bg.ignoresSafeArea(edges: .bottom))
    }

    private func tabItem(_ value: AppTab, _ icon: String, _ title: String) -> some View {
        let selected = tab == value
        return Button {
            tab = value
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selected ? TK.accent : TK.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

struct TKAction: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(TK.button)
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(TK.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TokenRow: View {
    let token: FakeToken

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: token.iconColorHex))
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(token.iconColorHex == "000000" ? 0.25 : 0), lineWidth: 1)
                )
                .overlay(
                    Text(String(token.symbol.prefix(1)))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(token.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(tkUSD(token.usdPrice))
                    .font(.system(size: 13))
                    .foregroundColor(TK.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(tkAmount(token.balance))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(tkUSD(token.usdValue))
                    .font(.system(size: 13))
                    .foregroundColor(TK.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct Notice: Identifiable {
    let title: String
    var id: String { title }
}

func shortAddress(_ a: String) -> String {
    guard a.count > 12 else { return a }
    let prefix = a.prefix(4)
    let suffix = a.suffix(4)
    return "\(prefix)...\(suffix)"
}

func tkUSD(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
}

func tkAmount(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_US")
    formatter.groupingSeparator = ","
    formatter.decimalSeparator = "."
    if value >= 10000 {
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
    } else if value >= 1 {
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    } else {
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
    }
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

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
