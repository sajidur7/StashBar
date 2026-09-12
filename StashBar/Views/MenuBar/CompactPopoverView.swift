import SwiftUI
import SwiftData
import AppKit

public struct CompactPopoverView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @ObservedObject private var clipboardWatcher = ClipboardWatcher.shared

    @Query(
        filter: #Predicate<StashItem> { !$0.isArchived },
        sort: \StashItem.createdAt,
        order: .reverse
    ) private var allItems: [StashItem]

    @State private var searchText: String = ""
    @State private var filterMode: FilterMode = .all
    @State private var selectedIndex: Int = 0
    @State private var showingAddSheet: Bool = false
    @State private var manualUrlInput: String = ""
    @State private var stashSuccessToast: String? = nil

    enum FilterMode: String, CaseIterable {
        case all = "All"
        case pinned = "Pinned"
        case recent = "Recent"
    }

    public init() {}

    private var filteredItems: [StashItem] {
        let base: [StashItem]
        switch filterMode {
        case .all:
            base = allItems
        case .pinned:
            base = allItems.filter { $0.isPinned }
        case .recent:
            let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            base = allItems.filter { $0.createdAt >= oneDayAgo }
        }

        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Array(base.prefix(10))
        }

        let query = searchText.lowercased()
        return Array(base.filter {
            $0.title.lowercased().contains(query) ||
            $0.url.lowercased().contains(query) ||
            $0.host.lowercased().contains(query) ||
            $0.notes.lowercased().contains(query) ||
            $0.tags.contains { $0.lowercased().contains(query) }
        }.prefix(15))
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

            // Smart Clipboard Capture Banner (Linear Carbon Card with Acid Lime CTA)
            if let candidate = clipboardWatcher.candidateUrl, !clipboardWatcher.isAlreadyStashed {
                clipboardBanner(candidateUrl: candidate, host: clipboardWatcher.candidateHost ?? "link")
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Command Search Field & Linear Filter Pills
            VStack(spacing: 7) {
                QuickSearchField(text: $searchText, placeholder: "Search links, domains, tags...")
                filterPillsView
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)

            // Subtle Hairline Divider (#23252a)
            Rectangle()
                .fill(LinearTheme.graphite)
                .frame(height: 1)

            // Items Stream
            if filteredItems.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                StashRowView(
                                    item: item,
                                    isSelected: selectedIndex == index,
                                    onSelect: {
                                        selectedIndex = index
                                    },
                                    onDelete: {
                                        deleteItem(item)
                                    }
                                )
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 6)
                    }
                    .frame(maxHeight: 330)
                }
            }

            // Subtle Hairline Divider (#23252a)
            Rectangle()
                .fill(LinearTheme.graphite)
                .frame(height: 1)

            // Linear Command Footer
            footerView
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
        }
        .frame(width: 380)
        .background(LinearTheme.void)
        .overlay(
            Rectangle()
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
        .preferredColorScheme(.dark)
        .onAppear {
            let existing = Set(allItems.map { $0.url })
            clipboardWatcher.refresh(existingUrls: existing)
        }
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if selectedIndex < filteredItems.count - 1 {
                selectedIndex += 1
            }
            return .handled
        }
        .onKeyPress(.return) {
            handleReturnKey()
            return .handled
        }
        .sheet(isPresented: $showingAddSheet) {
            manualAddSheet
        }
        .overlay(alignment: .bottom) {
            if let toast = stashSuccessToast {
                toastView(text: toast)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 8) {
            // Brand Glyph & Wordmark (Lucide external-link vector in Acid Lime)
            HStack(spacing: 7) {
                StashBarIcon(size: 14, color: LinearTheme.acidLime, lineWidth: 2)

                Text("Stash Bar")
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundColor(LinearTheme.paper)

                KbdBadge("⌥S")
            }

            Spacer()

            // Open Full Canvas Window (⌘E)
            Button(action: openCanvasWindow) {
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.split.2x1")
                        .font(.system(size: 10))
                    Text("Canvas")
                        .font(.system(size: 11, weight: .medium))
                    KbdBadge("⌘E")
                }
                .foregroundColor(LinearTheme.mist)
                .padding(.horizontal, 8)
                .padding(.vertical, 3.5)
                .background(LinearTheme.carbon)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help("Open Full Window (⌘E)")

            // Menu with .menuIndicator(.hidden)
            Menu {
                Button("Add Link Manually...") {
                    showingAddSheet = true
                }
                Divider()
                Button("Open Extended Canvas") {
                    openCanvasWindow()
                }
                Divider()
                Button("Quit Stash Bar") {
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(LinearTheme.fog)
                    .frame(width: 22, height: 22)
                    .background(LinearTheme.carbon)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 1)
                    )
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 22, height: 22)
        }
    }

    // MARK: - Clipboard Auto-Detection Banner (Carbon Card with Acid Lime CTA)
    private func clipboardBanner(candidateUrl: String, host: String) -> some View {
        HStack(spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(LinearTheme.acidLime.opacity(0.12))
                    .frame(width: 26, height: 26)
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(LinearTheme.acidLime)
                    .font(.system(size: 11, weight: .medium))
            }

            VStack(alignment: .leading, spacing: 1.5) {
                HStack(spacing: 4) {
                    Text("Clipboard URL")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(LinearTheme.paper)

                    Text("(\(host))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(LinearTheme.fog)
                }

                Text(candidateUrl)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(LinearTheme.mist)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 4)

            // Primary Action Button: Acid Lime CTA (6px radius)
            Button(action: stashClipboardCandidate) {
                Text("↩ Stash")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(LinearTheme.void)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4.5)
                    .background(RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous).fill(LinearTheme.acidLime))
            }
            .buttonStyle(.plain)

            // Dismiss
            Button(action: { clipboardWatcher.dismissCandidate() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(LinearTheme.ash)
                    .padding(3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(LinearTheme.carbon)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Dynamic Pill Filters (Linear 9999px pills)
    private var filterPillsView: some View {
        HStack(spacing: 6) {
            ForEach(FilterMode.allCases, id: \.self) { mode in
                DynamicPill(
                    title: mode.rawValue,
                    isSelected: filterMode == mode,
                    action: {
                        filterMode = mode
                        selectedIndex = 0
                    }
                )
            }
            Spacer()

            Text("\(allItems.count) links")
                .font(.system(size: 10.5, weight: .regular, design: .monospaced))
                .foregroundColor(LinearTheme.ash)
        }
    }

    // MARK: - Empty State (Linear precision dark)
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            StashBarIcon(size: 24, color: LinearTheme.fog, lineWidth: 1.8)

            Text(searchText.isEmpty ? "No links stashed" : "No matching links")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(LinearTheme.paper)

            Text(searchText.isEmpty ? "Copy any URL to clipboard to capture instantly." : "Try clearing your search query.")
                .font(.system(size: 11.5))
                .foregroundColor(LinearTheme.fog)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .frame(maxWidth: 280)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Linear Command Footer
    private var footerView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                KbdBadge("↵")
                Text("Copy")
                    .font(.system(size: 10))
                    .foregroundColor(LinearTheme.fog)
            }

            HStack(spacing: 4) {
                KbdBadge("⌘↵")
                Text("Open")
                    .font(.system(size: 10))
                    .foregroundColor(LinearTheme.fog)
            }

            HStack(spacing: 4) {
                KbdBadge("⌫")
                Text("Del")
                    .font(.system(size: 10))
                    .foregroundColor(LinearTheme.fog)
            }

            Spacer()

            Button(action: openCanvasWindow) {
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 11))
                    .foregroundColor(LinearTheme.fog)
            }
            .buttonStyle(.plain)
            .help("Open Full Window (⌘E)")
        }
    }

    // MARK: - Actions
    private func handleReturnKey() {
        if clipboardWatcher.candidateUrl != nil, !clipboardWatcher.isAlreadyStashed {
            stashClipboardCandidate()
            return
        }

        guard selectedIndex < filteredItems.count else { return }
        let item = filteredItems[selectedIndex]

        if NSEvent.modifierFlags.contains(.command) {
            if let url = URL(string: item.url) {
                NSWorkspace.shared.open(url)
            }
        } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.url, forType: .string)
            showToast("Copied to clipboard!")
        }
    }

    private func stashClipboardCandidate() {
        if let item = clipboardWatcher.stashCandidate(in: modelContext) {
            showToast("Stashed: \(item.displayHost)")
        }
    }

    private func deleteItem(_ item: StashItem) {
        modelContext.delete(item)
        try? modelContext.save()
        if selectedIndex >= filteredItems.count && selectedIndex > 0 {
            selectedIndex -= 1
        }
    }

    private func openCanvasWindow() {
        openWindow(id: "extended-canvas")
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showToast(_ text: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            stashSuccessToast = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.1)) {
                stashSuccessToast = nil
            }
        }
    }

    // MARK: - Manual Add Sheet
    private var manualAddSheet: some View {
        VStack(spacing: 14) {
            Text("Add Link to Stash Bar")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(LinearTheme.paper)

            QuickSearchField(text: $manualUrlInput, placeholder: "https://...")
                .frame(width: 280)

            HStack(spacing: 8) {
                Button("Cancel") {
                    showingAddSheet = false
                    manualUrlInput = ""
                }
                .buttonStyle(GhostButtonStyle())
                .keyboardShortcut(.cancelAction)

                Button("Save Link") {
                    if let cleaned = URLSanitizer.sanitize(manualUrlInput) {
                        let item = StashItem(url: cleaned, originalUrl: manualUrlInput)
                        modelContext.insert(item)
                        try? modelContext.save()
                        Task {
                            await MetadataParser.resolveMetadata(for: item.id, urlString: cleaned, context: modelContext)
                        }
                    }
                    showingAddSheet = false
                    manualUrlInput = ""
                }
                .buttonStyle(GhostButtonStyle(isProminent: true))
                .keyboardShortcut(.defaultAction)
                .disabled(manualUrlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(LinearTheme.carbon)
        .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous).stroke(LinearTheme.graphite, lineWidth: 1))
    }

    private func toastView(text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark")
                .font(.system(size: 8.5, weight: .bold))
                .foregroundColor(LinearTheme.void)
            Text(text)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(LinearTheme.void)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearTheme.acidLime))
        .transition(.scale.combined(with: .opacity))
    }
}
