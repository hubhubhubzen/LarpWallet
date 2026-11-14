import SwiftUI

struct SendView: View {
    @EnvironmentObject var store: WalletStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSymbol: String = ""
    @State private var toAddress: String = ""
    @State private var amount: String = ""

    private var selected: FakeToken? {
        store.tokens.first { $0.symbol == selectedSymbol }
    }

    private var parsedAmount: Double? {
        Double(amount.replacingOccurrences(of: ",", with: "."))
    }

    private var fiatText: String {
        tkPrice((parsedAmount ?? 0) * (selected?.usdPrice ?? 0))
    }

    private var canSend: Bool {
        guard let amt = parsedAmount, amt > 0, !toAddress.isEmpty else { return false }
        return (selected?.balance ?? 0) >= amt
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TK.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    Menu {
                        ForEach(store.tokens) { token in
                            Button("\(token.symbol)  \(tkAmount(token.balance))") {
                                selectedSymbol = token.symbol
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedSymbol.isEmpty ? "Token" : selectedSymbol)
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(TK.button)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 8)

                    Spacer()

                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    Text(fiatText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(TK.secondary)
                        .padding(.top, 4)
                    if let selected {
                        Button("Max \(tkAmount(selected.balance))") {
                            amount = String(selected.balance)
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TK.accent)
                        .padding(.top, 12)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Получатель")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(TK.secondary)
                        TextField("UQ...", text: $toAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(TK.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)

                    Button {
                        guard let amt = parsedAmount, amt > 0 else { return }
                        store.send(symbol: selectedSymbol, amount: amt, to: toAddress)
                        dismiss()
                    } label: {
                        Text("Продолжить")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(canSend ? .white : TK.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canSend ? TK.accent : TK.button)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(!canSend)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Отправить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .toolbarBackground(TK.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if selectedSymbol.isEmpty {
                    selectedSymbol = store.tokens.first?.symbol ?? ""
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
