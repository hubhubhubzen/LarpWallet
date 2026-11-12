import SwiftUI

struct SendView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSymbol: String = ""
    @State private var toAddress: String = ""
    @State private var amount: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Token") {
                    Picker("Token", selection: $selectedSymbol) {
                        ForEach(store.tokens) { t in
                            Text("\(t.symbol) — \(t.balance, specifier: "%.2f")")
                                .tag(t.symbol)
                        }
                    }
                }
                Section("Recipient") {
                    TextField("UQ...", text: $toAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(.footnote, design: .monospaced))
                }
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Send")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        guard let amt = Double(amount), amt > 0 else { return }
                        store.send(symbol: selectedSymbol, amount: amt, to: toAddress)
                        dismiss()
                    }
                    .disabled(toAddress.isEmpty || Double(amount) == nil)
                }
            }
            .onAppear {
                if selectedSymbol.isEmpty {
                    selectedSymbol = store.tokens.first?.symbol ?? ""
                }
            }
        }
    }
}
