import SwiftUI
import UIKit

enum TK {
    static let bg = Color(hex: "0F1620")
    static let card = Color(hex: "1D2733")
    static let button = Color(hex: "1E2836")
    static let pill = Color(hex: "2A3344")
    static let accent = Color(hex: "3294FF")
    static let secondary = Color(hex: "8B95A7")
    static let green = Color(hex: "3DDC97")
    static let red = Color(hex: "FF5E66")
}

enum AppTab: Hashable {
    case wallet, trade, browser
}

struct ContentView: View {
    @EnvironmentObject var store: WalletStore
    @State private var tab: AppTab = .wallet
    @State private var showSettings = false
    @State private var showSend = false
    @State private var showReceive = false
    @State private var showActivity = false
    @State private var notice: Notice?

    var body: some View {
        ZStack {
            TK.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch tab {
                    case .wallet:
                        WalletHome(
                            showSettings: $showSettings,
                            showSend: $showSend,
                            showReceive: $showReceive,
                            showActivity: $showActivity,
                            notice: $notice
                        )
                    case .trade:
                        SimplePage(
                            title: "Трейд",
                            icon: "chart.line.uptrend.xyaxis",
                            message: "Здесь будет обмен и графики."
                        )
                    case .browser:
                        SimplePage(
                            title: "Браузер",
                            icon: "safari",
                            message: "Здесь будут приложения и сервисы."
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                TKTabBar(tab: $tab)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TK.bg.ignoresSafeArea())
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(store)
        }
        .sheet(isPresented: $showSend) {
            SendView().environmentObject(store)
        }
        .sheet(isPresented: $showReceive) {
            ReceiveView().environmentObject(store)
        }
        .sheet(isPresented: $showActivity) {
            ActivityView().environmentObject(store)
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
    @Binding var showActivity: Bool
    @Binding var notice: Notice?
    @State private var copied = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    headerIcon("viewfinder") { notice = Notice(title: "Сканер") }
                    Spacer()
                    Button { showSettings = true } label: {
                        HStack(spacing: 6) {
                            WalletGlyph()
                                .frame(width: 16, height: 16)
                            Text("Кошелёк")
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(TK.secondary)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(TK.pill)
                        .clipShape(Capsule())
                    }
                    Spacer()
                    headerIcon("clock") { showActivity = true }
                    headerIcon("gearshape") { showSettings = true }
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(TK.red)
                                .frame(width: 7, height: 7)
                                .offset(x: -6, y: 6)
                        }
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                HStack(alignment: .center, spacing: 6) {
                    Text(tkHero(store.totalUSD))
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    BatteryBolt()
                }
                .padding(.top, 22)

                Button {
                    UIPasteboard.general.string = store.address
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copied = false }
                } label: {
                    HStack(spacing: 6) {
                        Text(copied ? "Скопировано" : shortAddress(store.address))
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: copied ? "checkmark" : "square.on.square")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(TK.secondary)
                }
                .padding(.top, 8)

                HStack(spacing: 0) {
                    TKAction(title: "Отправить", icon: "arrow.up") { showSend = true }
                    TKAction(title: "Пополнить", icon: "arrow.down") { showReceive = true }
                    TKAction(title: "Обменять", icon: "arrow.up.arrow.down") { notice = Notice(title: "Обменять") }
                    TKAction(title: "Застейкать", icon: "stake") { notice = Notice(title: "Застейкать") }
                }
                .padding(.top, 26)
                .padding(.horizontal, 8)

                HStack {
                    HStack(spacing: 4) {
                        Text("Крипто")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(TK.secondary)
                    }
                    .foregroundColor(.white)
                    Spacer()
                    Button { showSettings = true } label: {
                        HStack(spacing: 6) {
                            Text("Управлять")
                                .font(.system(size: 15, weight: .medium))
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(TK.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 10)

                VStack(spacing: 2) {
                    ForEach(store.tokens) { token in
                        TokenRow(token: token)
                    }
                }
                .padding(.vertical, 6)
                .background(TK.card)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
        }
    }

    private func headerIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
        }
    }
}

struct ActivityView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                TK.bg.ignoresSafeArea()
                if store.history.isEmpty {
                    SimplePage(
                        title: "История",
                        icon: "clock",
                        message: "Отправленные переводы появятся здесь."
                    )
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
                                        Text("Отправлено")
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
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct SimplePage: View {
    let title: String
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .regular))
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
                SimplePage(
                    title: title,
                    icon: title == "Сканер" ? "viewfinder" : (title == "Застейкать" ? "chart.line.uptrend.xyaxis" : "arrow.up.arrow.down"),
                    message: title == "Сканер" ? "Наведите камеру на QR-код." : "Этот раздел пока пустой."
                )
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
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
                                .font(.system(size: 120))
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
                        Text(copied ? "Скопировано" : "Скопировать адрес")
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
            .navigationTitle("Пополнить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
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
        HStack {
            tabItem(.wallet, "wallet", "Кошелёк")
            tabItem(.trade, "chart.line.uptrend.xyaxis", "Трейд")
            tabItem(.browser, "safari", "Браузер")
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background(TK.bg.ignoresSafeArea(edges: .bottom))
    }

    private func tabItem(_ value: AppTab, _ icon: String, _ title: String) -> some View {
        let selected = tab == value
        return Button {
            tab = value
        } label: {
            VStack(spacing: 3) {
                Group {
                    if icon == "wallet" {
                        WalletGlyph(filled: true)
                            .frame(width: 22, height: 22)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: selected ? .semibold : .regular))
                    }
                }
                Text(title)
                    .font(.system(size: 11, weight: .medium))
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
            VStack(spacing: 7) {
                Group {
                    if icon == "stake" {
                        StakeGlyph()
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .regular))
                    }
                }
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(TK.button)
                .clipShape(Circle())
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(TK.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct TokenRow: View {
    let token: FakeToken

    var body: some View {
        HStack(spacing: 12) {
            TokenIcon(token: token)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(token.symbol)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    if let network = token.network {
                        Text(network)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(TK.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(TK.accent)
                }
                HStack(spacing: 6) {
                    Text(tkPrice(token.usdPrice))
                        .font(.system(size: 13))
                        .foregroundColor(TK.secondary)
                    Text(tkPercent(token.priceChange))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(token.priceChange < 0 ? TK.red : TK.green)
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 3) {
                Text(tkAmount(token.balance))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(token.usdValue == 0 ? "$0" : tkPrice(token.usdValue))
                    .font(.system(size: 13))
                    .foregroundColor(TK.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

struct BatteryBolt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(TK.accent)
                .frame(width: 22, height: 12)
            RoundedRectangle(cornerRadius: 0.8)
                .fill(TK.accent)
                .frame(width: 2, height: 5)
                .offset(x: 12.5)
            Image(systemName: "bolt.fill")
                .font(.system(size: 8, weight: .black))
                .foregroundColor(TK.bg)
        }
        .frame(width: 28, height: 16)
    }
}

struct WalletGlyph: View {
    var filled: Bool = false

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var card = Path()
            card.addRoundedRect(
                in: CGRect(x: w * 0.06, y: h * 0.30, width: w * 0.88, height: h * 0.60),
                cornerSize: CGSize(width: w * 0.12, height: w * 0.12)
            )
            var flap = Path()
            flap.move(to: CGPoint(x: w * 0.14, y: h * 0.36))
            flap.addLine(to: CGPoint(x: w * 0.38, y: h * 0.10))
            flap.addLine(to: CGPoint(x: w * 0.90, y: h * 0.10))
            flap.addLine(to: CGPoint(x: w * 0.90, y: h * 0.36))
            flap.closeSubpath()
            if filled {
                context.fill(card, with: .foreground)
                context.fill(flap, with: .foreground)
            } else {
                context.stroke(card, with: .foreground, lineWidth: 1.5)
                context.stroke(flap, with: .foreground, lineWidth: 1.5)
            }
        }
    }
}

struct StakeGlyph: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            RoundedRectangle(cornerRadius: 0.6).frame(width: 3.5, height: 7)
            RoundedRectangle(cornerRadius: 0.6).frame(width: 3.5, height: 11)
            RoundedRectangle(cornerRadius: 0.6).frame(width: 3.5, height: 16)
        }
        .foregroundColor(.white)
    }
}

struct TokenIcon: View {
    let token: FakeToken

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: token.iconColorHex))
            mark
        }
        .frame(width: 40, height: 40)
        .overlay(alignment: .bottomTrailing) {
            if token.symbol == "USDT" {
                Image(systemName: "triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: "FF2D55"))
                    .offset(x: 1, y: 1)
            }
        }
        .overlay(alignment: .bottomLeading) {
            if token.symbol == "USDC" {
                Circle()
                    .fill(Color(hex: "1B3A4B"))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(TK.card, lineWidth: 1.5))
                    .offset(x: -1, y: 1)
            }
        }
    }

    @ViewBuilder
    private var mark: some View {
        switch token.symbol {
        case "ETH":
            EthMark()
        case "BNB":
            BnbMark()
        case "SOL":
            SolMark()
        case "USDT":
            Diamond()
                .stroke(.white, style: StrokeStyle(lineWidth: 2.2, lineJoin: .round))
                .frame(width: 16, height: 20)
        case "USDC":
            Text("$")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        default:
            Text(String(token.symbol.prefix(1)))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct EthMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var top = Path()
            top.move(to: CGPoint(x: w * 0.50, y: 0))
            top.addLine(to: CGPoint(x: w, y: h * 0.42))
            top.addLine(to: CGPoint(x: w * 0.50, y: h * 0.58))
            top.addLine(to: CGPoint(x: 0, y: h * 0.42))
            top.closeSubpath()
            var bottom = Path()
            bottom.move(to: CGPoint(x: 0, y: h * 0.50))
            bottom.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            bottom.addLine(to: CGPoint(x: w, y: h * 0.50))
            bottom.addLine(to: CGPoint(x: w * 0.50, y: h))
            bottom.closeSubpath()
            context.fill(top, with: .color(.white))
            context.fill(bottom, with: .color(.white.opacity(0.78)))
        }
        .frame(width: 18, height: 26)
    }
}

struct BnbMark: View {
    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            func diamond(center: CGPoint, radius: CGFloat) -> Path {
                var path = Path()
                path.move(to: CGPoint(x: center.x, y: center.y - radius))
                path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
                path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
                path.closeSubpath()
                return path
            }
            let mid = CGPoint(x: s / 2, y: s / 2)
            let r = s * 0.16
            let d = s * 0.28
            for point in [
                mid,
                CGPoint(x: mid.x, y: mid.y - d),
                CGPoint(x: mid.x + d, y: mid.y),
                CGPoint(x: mid.x, y: mid.y + d),
                CGPoint(x: mid.x - d, y: mid.y)
            ] {
                context.fill(diamond(center: point, radius: r), with: .color(.white))
            }
        }
        .frame(width: 22, height: 22)
    }
}

struct SolMark: View {
    var body: some View {
        Canvas { context, size in
            let colors = [
                Color(hex: "9945FF"),
                Color(hex: "19FB9B"),
                Color(hex: "80ECFF")
            ]
            let bar = size.height / 4.2
            let gap = bar * 0.45
            let skew = size.width * 0.22
            for index in 0..<3 {
                let y = CGFloat(index) * (bar + gap)
                var path = Path()
                path.move(to: CGPoint(x: skew, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                path.addLine(to: CGPoint(x: size.width - skew, y: y + bar))
                path.addLine(to: CGPoint(x: 0, y: y + bar))
                path.closeSubpath()
                context.fill(path, with: .color(colors[index]))
            }
        }
        .frame(width: 20, height: 16)
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Notice: Identifiable {
    let title: String
    var id: String { title }
}

func shortAddress(_ a: String) -> String {
    guard a.count > 10 else { return a }
    return "\(a.prefix(4))...\(a.suffix(4))"
}

func tkHero(_ value: Double) -> String {
    "$ \(tkGrouped(value))"
}

func tkPrice(_ value: Double) -> String {
    "$\(tkGrouped(value))"
}

func tkGrouped(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.decimalSeparator = ","
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = value >= 100 ? 2 : 3
    return formatter.string(from: NSNumber(value: value)) ?? "0,00"
}

func tkPercent(_ value: Double) -> String {
    if value > 0 { return String(format: "+%.2f%%", value) }
    return String(format: "%.2f%%", value)
}

func tkAmount(_ value: Double) -> String {
    if value == 0 { return "0" }
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.decimalSeparator = ","
    formatter.maximumFractionDigits = value >= 1000 ? 0 : 2
    formatter.minimumFractionDigits = 0
    return formatter.string(from: NSNumber(value: value)) ?? "0"
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
