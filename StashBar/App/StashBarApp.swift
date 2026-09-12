import SwiftUI
import SwiftData
import AppKit

@main
public struct StashBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow

    public var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StashItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    public init() {}

    public var body: some Scene {
        // Status Bar Popover (Exact Lucide external-link vector)
        MenuBarExtra {
            CompactPopoverView()
                .modelContainer(sharedModelContainer)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenExtendedCanvas"))) { _ in
                    openWindow(id: "extended-canvas")
                }
        } label: {
            Image(nsImage: StashBarIcon.menuBarImage)
        }
        .menuBarExtraStyle(.window)

        // Extended Multi-pane Window
        WindowGroup("Stash Bar", id: "extended-canvas") {
            ExtendedCanvasView()
                .modelContainer(sharedModelContainer)
                .frame(minWidth: 860, minHeight: 560)
        }
        .defaultSize(width: 1000, height: 660)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Extended Canvas") {
                    openWindow(id: "extended-canvas")
                }
                .keyboardShortcut("e", modifiers: [.command])
            }
        }
    }
}
