import SwiftUI
import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as an accessory app (lives in the menu bar, no dock clutter)
        NSApp.setActivationPolicy(.accessory)

        setupHotkeyMonitors()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        if let local = localEventMonitor {
            NSEvent.removeMonitor(local)
        }
        if let global = globalEventMonitor {
            NSEvent.removeMonitor(global)
        }
    }

    private func setupHotkeyMonitors() {
        // Monitor for Option + S (⌥ + S) and Command + E (⌘ + E)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil // consume event
            }
            return event
        }

        // Global monitor for Option + S (when other apps are in foreground)
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            _ = self?.handleKeyEvent(event)
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Check for Option + S (⌥ + S)
        if flags == .option && event.charactersIgnoringModifiers?.lowercased() == "s" {
            triggerOptionSHotkey()
            return true
        }

        // Check for Command + E (⌘ + E)
        if flags == .command && event.charactersIgnoringModifiers?.lowercased() == "e" {
            openExtendedCanvas()
            return true
        }

        return false
    }

    public func triggerOptionSHotkey() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            // Trigger pasteboard check
            ClipboardWatcher.shared.checkPasteboard(forced: true)
        }
    }

    public func openExtendedCanvas() {
        DispatchQueue.main.async {
            // Temporarily set to regular so window manages focus smoothly
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)

            // Try to find or bring forward existing canvas window
            for window in NSApp.windows where window.identifier?.rawValue == "extended-canvas" || window.title.contains("Stash Bar") || window.title.contains("Canvas") {
                window.makeKeyAndOrderFront(nil)
                return
            }

            // Otherwise trigger openWindow via notification or selector
            NotificationCenter.default.post(name: Notification.Name("OpenExtendedCanvas"), object: nil)
        }
    }
}
