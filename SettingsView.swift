import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss
    @State private var draftAddress: String = ""
    @State private var showAddToken = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Wallet Address") {
                    TextField("Address", text: $draftAddress)
                        .font(.system(.footnote, design: .monospaced))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Button("Save Address") {
                        store.address = draftAddress.trimmingCharacters(in: .whitespaces)
                    }
                    .disabled(draftAddress.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Section("Tokens") {
                    ForEach(store.tokens) { token in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(token.name) (\(token.symbol))")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text(String(format: "$%.2f", token.usdValue))
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            HStack {
                                Text("Balance:")
                                TextField("0", value: Binding(
                                    get: { token.balance },
                                    set: { store.updateBalance(tokenID: token.id, newBalance: $0) }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            }
                            .font(.system(size: 13))
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { idx in
                        idx.forEach { store.deleteToken(store.tokens[$0]) }
                    }

                    Button {
                        showAddToken = true
                    } label: {
                        Label("Add Token", systemImage: "plus.circle.fill")
                    }
                }

                Section("Danger") {
                    Button("Reset All Data", role: .destructive) {
                        UserDefaults.standard.removeObject(forKey: "tonkeeper_fake_state_v1")
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(TK.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { draftAddress = store.address }
            .sheet(isPresented: $showAddToken) {
                AddTokenView()
                    .environmentObject(store)
            }
        }
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
                TextField("Balance", text: $balance)
                    .keyboardType(.decimalPad)
                TextField("USD Price", text: $price)
                    .keyboardType(.decimalPad)
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
                            balance: Double(balance) ?? 0,
                            usdPrice: Double(price) ?? 0,
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
