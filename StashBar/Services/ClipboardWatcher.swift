import SwiftUI
import AppKit
import SwiftData
import Combine

@MainActor
public final class ClipboardWatcher: ObservableObject {
    public static let shared = ClipboardWatcher()

    @Published public var rawCandidateUrl: String?
    @Published public var candidateUrl: String?
    @Published public var candidateHost: String?
    @Published public var isAlreadyStashed: Bool = false
    @Published public var lastStashedUrl: String?

    private var lastChangeCount: Int = -1
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    public init() {
        startMonitoring()
    }

    public func startMonitoring() {
        // Poll every 1 second for pasteboard changes
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkPasteboard()
            }
        }
        checkPasteboard()
    }

    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    /// Explicitly refreshes the pasteboard status (e.g. when menu bar popover opens)
    public func refresh(existingUrls: Set<String> = []) {
        checkPasteboard(forced: true, existingUrls: existingUrls)
    }

    public func checkPasteboard(forced: Bool = false, existingUrls: Set<String> = []) {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        if !forced && currentChangeCount == lastChangeCount {
            return
        }
        lastChangeCount = currentChangeCount

        // 1. Try reading URL string
        var candidateText: String?
        if let string = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty {
            candidateText = string
        } else if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let first = urls.first {
            candidateText = first.absoluteString
        }

        guard let text = candidateText, URLSanitizer.isValidUrl(text) else {
            self.rawCandidateUrl = nil
            self.candidateUrl = nil
            self.candidateHost = nil
            self.isAlreadyStashed = false
            return
        }

        let raw = text
        guard let sanitized = URLSanitizer.sanitize(raw) else {
            self.rawCandidateUrl = nil
            self.candidateUrl = nil
            self.candidateHost = nil
            self.isAlreadyStashed = false
            return
        }

        self.rawCandidateUrl = raw
        self.candidateUrl = sanitized
        self.candidateHost = URLSanitizer.cleanHost(from: sanitized)
        self.isAlreadyStashed = existingUrls.contains(sanitized)
    }

    /// Stashes the current clipboard candidate into SwiftData and starts metadata resolution
    @discardableResult
    public func stashCandidate(in context: ModelContext) -> StashItem? {
        guard let cleanUrl = candidateUrl else { return nil }

        let item = StashItem(
            url: cleanUrl,
            originalUrl: rawCandidateUrl ?? cleanUrl,
            title: candidateHost ?? cleanUrl,
            host: candidateHost ?? "link"
        )

        context.insert(item)
        try? context.save()

        lastStashedUrl = cleanUrl
        isAlreadyStashed = true

        // Kick off metadata fetch in the background
        Task {
            await MetadataParser.resolveMetadata(for: item.id, urlString: cleanUrl, context: context)
        }

        // Haptic / audio feedback
        NSSound.beep()

        return item
    }

    public func dismissCandidate() {
        self.candidateUrl = nil
        self.rawCandidateUrl = nil
        self.candidateHost = nil
    }
}
