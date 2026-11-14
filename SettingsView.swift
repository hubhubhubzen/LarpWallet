import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss
    @State private var draftAddress: String = ""
    @State private var showAddToken = false
    @State private var balanceDraft: [UUID: String] = [:]
    @State private var priceDraft: [UUID: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                Section("Адрес") {
                    TextField("Address", text: $draftAddress)
                        .font(.system(.footnote, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.default)
                    Button("Сохранить адрес") {
                        store.address = draftAddress.trimmingCharacters(in: .whitespaces)
                    }
                    .disabled(draftAddress.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Section("Монеты") {
                    ForEach(store.tokens) { token in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(token.name) (\(token.symbol))")
                                .font(.system(size: 14, weight: .semibold))
                            HStack {
                                Text("Баланс")
                                TextField("0", text: draftBinding(token.id, store: balanceDraft, value: token.balance) { text in
                                    balanceDraft[token.id] = text
                                    if let number = parseLoose(text) {
                                        store.updateBalance(tokenID: token.id, newBalance: number)
                                    }
                                })
                                .keyboardType(.default)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                            }
                            HStack {
                                Text("Цена, $")
                                TextField("0", text: draftBinding(token.id, store: priceDraft, value: token.usdPrice) { text in
                                    priceDraft[token.id] = text
                                    if let number = parseLoose(text) {
                                        store.updatePrice(tokenID: token.id, newPrice: number)
                                    }
                                })
                                .keyboardType(.default)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                            }
                        }
                        .font(.system(size: 15))
                        .padding(.vertical, 4)
                    }
                    .onDelete { idx in
                        idx.forEach { store.deleteToken(store.tokens[$0]) }
                    }

                    Button {
                        showAddToken = true
                    } label: {
                        Label("Добавить монету", systemImage: "plus.circle.fill")
                    }
                }

                Section("Сброс") {
                    Button("Сбросить данные", role: .destructive) {
                        UserDefaults.standard.removeObject(forKey: WalletStore.storageKey)
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TK.bg)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                draftAddress = store.address
                for token in store.tokens {
                    if balanceDraft[token.id] == nil {
                        balanceDraft[token.id] = formatDraft(token.balance)
                    }
                    if priceDraft[token.id] == nil {
                        priceDraft[token.id] = formatDraft(token.usdPrice)
                    }
                }
            }
            .sheet(isPresented: $showAddToken) {
                AddTokenView()
                    .environmentObject(store)
            }
        }
    }

    private func draftBinding(_ id: UUID, store: [UUID: String], value: Double, write: @escaping (String) -> Void) -> Binding<String> {
        Binding(
            get: { store[id] ?? formatDraft(value) },
            set: write
        )
    }
}

struct AddTokenView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var symbol = ""
    @State private var balance = ""
    @State private var price = ""
    @State private var colorHex = "0098EA"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name (e.g. Bitcoin)", text: $name)
                TextField("Symbol (e.g. BTC)", text: $symbol)
                    .autocapitalization(.allCharacters)
                TextField("Баланс", text: $balance)
                    .keyboardType(.default)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Цена, $", text: $price)
                    .keyboardType(.default)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Icon Color Hex (e.g. F7931A)", text: $colorHex)
                    .autocapitalization(.none)
            }
            .scrollContentBackground(.hidden)
            .background(TK.bg)
            .navigationTitle("New Token")
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let token = FakeToken(
                            name: name.isEmpty ? "Custom" : name,
                            symbol: symbol.isEmpty ? "CST" : symbol.uppercased(),
                            balance: parseLoose(balance) ?? 0,
                            usdPrice: parseLoose(price) ?? 0,
                            iconColorHex: colorHex
                        )
                        store.addToken(token)
                        dismiss()
                    }
                    .disabled(symbol.isEmpty)
                }
            }
        }
    }
}

func parseLoose(_ text: String) -> Double? {
    let cleaned = text
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: ",", with: ".")
        .trimmingCharacters(in: .whitespaces)
    if cleaned.isEmpty { return nil }
    return Double(cleaned)
}

func formatDraft(_ value: Double) -> String {
    if value == 0 { return "0" }
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 8
    return formatter.string(from: NSNumber(value: value)) ?? "0"
}
