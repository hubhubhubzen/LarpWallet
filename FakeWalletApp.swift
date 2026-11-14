import SwiftUI
import UIKit

@main
struct FakeWalletApp: App {
    @StateObject private var store = WalletStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(TK.bg.ignoresSafeArea())
                .background(WindowFill())
                .preferredColorScheme(.dark)
        }
    }
}

/// iOS sizes this app's window smaller than the iPhone and leaves black around it.
/// Stretch that window to the screen after launch and paint it the app color.
struct WindowFill: UIViewRepresentable {
    func makeUIView(context: Context) -> FillView { FillView() }
    func updateUIView(_ uiView: FillView, context: Context) { uiView.stretch() }
}

final class FillView: UIView {
    private static let fill = UIColor(red: 23.0 / 255.0, green: 26.0 / 255.0, blue: 34.0 / 255.0, alpha: 1)
    private var stretching = false
    private var attempts = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { nil }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        attempts = 0
        stretch()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stretch()
    }

    func stretch() {
        guard attempts < 8, !stretching, let window else { return }
        stretching = true
        attempts += 1
        defer { stretching = false }

        let screenObj = window.windowScene?.screen
        let full: CGRect
        if let screenObj {
            let pixels = screenObj.nativeBounds
            let scale = max(screenObj.nativeScale, 1)
            full = CGRect(x: 0, y: 0, width: pixels.width / scale, height: pixels.height / scale)
        } else {
            full = window.bounds
        }
        window.backgroundColor = Self.fill
        if window.frame.size != full.size {
            window.frame = full
        }

        guard let root = window.rootViewController else { return }
        root.view.backgroundColor = Self.fill
        root.view.layer.cornerRadius = 0
        root.view.clipsToBounds = false
        root.view.insetsLayoutMarginsFromSafeArea = false
        if root.view.frame.size != full.size {
            root.view.frame = full
        }

        DispatchQueue.main.async { [weak self] in
            self?.stretch()
        }
    }
}
