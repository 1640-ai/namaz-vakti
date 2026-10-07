import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = Store()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private var abonelik: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: AnaGorunum(store: store))

        if let dugme = statusItem.button {
            dugme.target = self
            dugme.action = #selector(degistir)
        }
        abonelik = store.$simdi.sink { [weak self] _ in
            Task { @MainActor in self?.basligiGuncelle() }
        }
        basligiGuncelle()
    }

    private func basligiGuncelle() {
        let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        var ozellik: [NSAttributedString.Key: Any] = [.font: font]
        if let renk = store.uyariRengi { ozellik[.foregroundColor] = renk }
        statusItem.button?.attributedTitle = NSAttributedString(string: store.menuMetni, attributes: ozellik)
    }

    @objc private func degistir() {
        guard let dugme = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: dugme.bounds, of: dugme, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
