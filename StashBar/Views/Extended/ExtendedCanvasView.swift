import SwiftUI
import SwiftData
import AppKit

public struct ExtendedCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StashItem.createdAt, order: .reverse) private var allItems: [StashItem]

    @State private var selectedFilter: CanvasFilter = .all
    @State private var selectedItem: StashItem?
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .newest
    @State private var showingAddSheet: Bool = false
    @State private var newUrlInput: String = ""
    @State private var toastMessage: String? = nil

    enum CanvasFilter: Hashable {
        case all
        case pinned
        case recent
        case archived
        case domain(String)
    }

    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case host = "Domain"
        case title = "Title"
    }

    public init() {}

    private var activeItems: [StashItem] {
        allItems.filter { !$0.isArchived }
    }

    private var pinnedCount: Int {
        activeItems.filter { $0.isPinned }.count
    }

    private var recentCount: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return activeItems.filter { $0.createdAt >= sevenDaysAgo }.count
    }

    private var archivedCount: Int {
        allItems.filter { $0.isArchived }.count
    }

    private var domainCounts: [(domain: String, count: Int)] {
        var counts: [String: Int] = [:]
        for item in activeItems {
            counts[item.displayHost, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map { (domain: $0.key, count: $0.value) }
    }

    private var filteredItems: [StashItem] {
        var base: [StashItem]

        switch selectedFilter {
        case .all:
            base = activeItems
        case .pinned:
            base = activeItems.filter { $0.isPinned }
        case .recent:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            base = activeItems.filter { $0.createdAt >= sevenDaysAgo }
        case .archived:
            base = allItems.filter { $0.isArchived }
        case .domain(let domain):
            base = activeItems.filter { $0.displayHost == domain }
        }

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.lowercased()
            base = base.filter {
                $0.title.lowercased().contains(query) ||
                $0.url.lowercased().contains(query) ||
                $0.host.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query) ||
                $0.tags.contains { $0.lowercased().contains(query) }
            }
        }

        switch sortOption {
        case .newest:
            return base.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return base.sorted { $0.createdAt < $1.createdAt }
        case .host:
            return base.sorted { $0.displayHost < $1.displayHost }
        case .title:
            return base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Linear Top Command Bar (#08090a canvas with 1px #23252a bottom border)
            topCommandBar
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

            // Linear Horizontal Filter Rail (9999px pills, Berkeley Mono counters)
            filterPillRail
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            // Hairline Divider (#23252a)
            Rectangle()
                .fill(LinearTheme.graphite)
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            // Workspace Area (Linear midnight precision)
            if allItems.isEmpty {
                // Entire database empty -> Full-width Linear empty card
                emptyVaultView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            } else if filteredItems.isEmpty {
                // Filter or search has 0 matches -> 100% Full-width Linear empty card
                emptyFilterView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            } else {
                // Items present -> Stream table (370px) + Linear property inspector
                HStack(spacing: 12) {
                    leftStreamPane
                        .frame(width: 370)

                    rightInspectorPane
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(minWidth: 880, minHeight: 580)
        .background(LinearTheme.void)
        .preferredColorScheme(.dark)
        .onAppear {
            if selectedItem == nil {
                selectedItem = filteredItems.first
            }
        }
        .onChange(of: filteredItems) { _, newItems in
            if let current = selectedItem, !newItems.contains(where: { $0.id == current.id }) {
                selectedItem = newItems.first
            } else if selectedItem == nil {
                selectedItem = newItems.first
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            addLinkSheet
        }
        .overlay(alignment: .bottom) {
            if let toast = toastMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundColor(LinearTheme.void)
                    Text(toast)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(LinearTheme.void)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearTheme.acidLime))
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Linear Command Bar
    private var topCommandBar: some View {
        HStack(spacing: 12) {
            // Brand identification (Lucide vector in Acid Lime + STASH BAR)
            HStack(spacing: 7) {
                StashBarIcon(size: 15, color: LinearTheme.acidLime, lineWidth: 2)

                Text("STASH BAR")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(LinearTheme.paper)

                Text("//")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(LinearTheme.smoke)

                Text("\(allItems.count)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(LinearTheme.fog)
            }

            // Command Search Input (6px radius, #0f1011 fill, #23252a hairline)
            QuickSearchField(text: $searchText, placeholder: "Search links, domains, tags...")
                .frame(width: 270)

            // Sort Selector Menu (6px Linear button, .menuIndicator(.hidden))
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: { sortOption = option }) {
                        HStack {
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 9.5))
                    Text(sortOption.rawValue)
                        .font(.system(size: 11.5, weight: .medium))
                }
                .foregroundColor(LinearTheme.mist)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(LinearTheme.carbon)
                .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()

            Spacer()

            // Primary Action: Electric Acid Lime CTA (#e4f222, 6px radius, Inter 13px/510)
            Button(action: { showingAddSheet = true }) {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("New Link")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(LinearTheme.void)
                .padding(.horizontal, 12)
                .padding(.vertical, 6.5)
                .background(
                    RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous)
                        .fill(LinearTheme.acidLime)
                )
            }
            .buttonStyle(.plain)

            // Export Menu (6px square button, .menuIndicator(.hidden))
            Menu {
                Button("Export as Markdown to Clipboard") {
                    exportAsMarkdown()
                }
                Button("Export as JSON to Clipboard") {
                    exportAsJSON()
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(LinearTheme.fog)
                    .frame(width: 28, height: 28)
                    .background(LinearTheme.carbon)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 1)
                    )
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 28, height: 28)
        }
    }

    // MARK: - Linear Dynamic Filter Rail (9999px pills)
    private var filterPillRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                DynamicPill(
                    title: "All",
                    count: activeItems.count,
                    icon: "tray",
                    isSelected: selectedFilter == .all
                ) {
                    selectedFilter = .all
                }

                DynamicPill(
                    title: "Pinned",
                    count: pinnedCount > 0 ? pinnedCount : nil,
                    icon: "pin.fill",
                    isSelected: selectedFilter == .pinned
                ) {
                    selectedFilter = .pinned
                }

                DynamicPill(
                    title: "Last 7 Days",
                    count: recentCount > 0 ? recentCount : nil,
                    icon: "clock",
                    isSelected: selectedFilter == .recent
                ) {
                    selectedFilter = .recent
                }

                DynamicPill(
                    title: "Archive",
                    count: archivedCount > 0 ? archivedCount : nil,
                    icon: "archivebox",
                    isSelected: selectedFilter == .archived
                ) {
                    selectedFilter = .archived
                }

                if !domainCounts.isEmpty {
                    Rectangle()
                        .fill(LinearTheme.smoke)
                        .frame(width: 1, height: 14)
                        .padding(.horizontal, 2)

                    ForEach(domainCounts.prefix(7), id: \.domain) { entry in
                        DynamicPill(
                            title: entry.domain,
                            count: entry.count,
                            isSelected: selectedFilter == .domain(entry.domain)
                        ) {
                            if selectedFilter == .domain(entry.domain) {
                                selectedFilter = .all
                            } else {
                                selectedFilter = .domain(entry.domain)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Left Stream Pane (Carbon #0f1011 with 12px radius & #23252a hairline border)
    private var leftStreamPane: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(filteredItems) { item in
                    StashRowView(
                        item: item,
                        isSelected: selectedItem?.id == item.id,
                        onSelect: {
                            selectedItem = item
                        },
                        onDelete: {
                            deleteItem(item)
                        }
                    )
                }
            }
            .padding(6)
        }
        .background(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .fill(LinearTheme.carbon)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Right Inspector Pane (Carbon #0f1011 with 12px radius)
    private var rightInspectorPane: some View {
        ZStack {
            if let item = selectedItem {
                LinkDetailView(item: item)
                    .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous))
            } else {
                // Linear Inspector Placeholder
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LinearTheme.obsidian)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(LinearTheme.graphite, lineWidth: 1)
                            )

                        Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                            .font(.system(size: 16))
                            .foregroundColor(LinearTheme.fog)
                    }

                    Text("Select a link to inspect")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LinearTheme.paper)

                    Text("View metadata, annotations, clean tracking inspection, and export options.")
                        .font(.system(size: 12))
                        .foregroundColor(LinearTheme.fog)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .frame(maxWidth: 300)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                        .fill(LinearTheme.carbon)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Full Width Empty Filter View (100% full width Carbon card)
    private var emptyFilterView: some View {
        VStack(spacing: 12) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearTheme.obsidian)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 1)
                    )

                StashBarIcon(size: 22, color: LinearTheme.fog, lineWidth: 1.8)
            }

            Text("No matching links")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(LinearTheme.paper)

            Text("Try clearing your search query or selecting a different filter.")
                .font(.system(size: 12.5))
                .foregroundColor(LinearTheme.fog)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .fixedSize(horizontal: false, vertical: true)

            if !searchText.isEmpty || selectedFilter != .all {
                Button(action: {
                    searchText = ""
                    selectedFilter = .all
                }) {
                    Text("Reset Filter")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(LinearTheme.void)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous)
                                .fill(LinearTheme.acidLime)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .fill(LinearTheme.carbon)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Full Canvas Empty State (When zero items in database)
    private var emptyVaultView: some View {
        VStack(spacing: 14) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearTheme.obsidian)
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 1)
                    )

                StashBarIcon(size: 26, color: LinearTheme.acidLime, lineWidth: 2)
            }

            Text("Your stash is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(LinearTheme.paper)

            Text("Copy any URL to your clipboard to capture instantly, or stash your first link manually.")
                .font(.system(size: 12.5))
                .foregroundColor(LinearTheme.fog)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .frame(maxWidth: 340)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: { showingAddSheet = true }) {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("Add First Link")
                        .font(.system(size: 12.5, weight: .semibold))
                }
                .foregroundColor(LinearTheme.void)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous)
                        .fill(LinearTheme.acidLime)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .fill(LinearTheme.carbon)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Add Link Sheet (Linear Carbon Modal)
    private var addLinkSheet: some View {
        VStack(spacing: 16) {
            Text("Add Link to Stash Bar")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(LinearTheme.paper)

            QuickSearchField(text: $newUrlInput, placeholder: "https://...")
                .frame(width: 300)

            HStack(spacing: 8) {
                Button("Cancel") {
                    showingAddSheet = false
                    newUrlInput = ""
                }
                .buttonStyle(GhostButtonStyle())
                .keyboardShortcut(.cancelAction)

                Button("Save Link") {
                    if let cleaned = URLSanitizer.sanitize(newUrlInput) {
                        let item = StashItem(url: cleaned, originalUrl: newUrlInput)
                        modelContext.insert(item)
                        try? modelContext.save()
                        selectedItem = item
                        Task {
                            await MetadataParser.resolveMetadata(for: item.id, urlString: cleaned, context: modelContext)
                        }
                    }
                    showingAddSheet = false
                    newUrlInput = ""
                }
                .buttonStyle(GhostButtonStyle(isProminent: true))
                .keyboardShortcut(.defaultAction)
                .disabled(newUrlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 360)
        .background(LinearTheme.carbon)
        .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusCard, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Actions & Export
    private func deleteItem(_ item: StashItem) {
        if selectedItem?.id == item.id {
            selectedItem = nil
        }
        modelContext.delete(item)
        try? modelContext.save()
    }

    private func exportAsMarkdown() {
        var md = "# Stash Bar Export (\(Date().formatted(date: .abbreviated, time: .omitted)))\n\n"
        for item in allItems where !item.isArchived {
            md += "- [\(item.title)](\(item.url)) (\(item.displayHost))\n"
            if let desc = item.itemDescription, !desc.isEmpty {
                md += "  > \(desc)\n"
            }
            if !item.notes.isEmpty {
                md += "  *Notes: \(item.notes)*\n"
            }
            md += "\n"
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(md, forType: .string)
        showToastNotice("Exported \(allItems.count) links as Markdown")
    }

    private func exportAsJSON() {
        struct ExportItem: Codable {
            let title: String
            let url: String
            let host: String
            let originalUrl: String
            let notes: String
            let tags: [String]
            let createdAt: String
        }

        let exportList = allItems.map {
            ExportItem(
                title: $0.title,
                url: $0.url,
                host: $0.host,
                originalUrl: $0.originalUrl,
                notes: $0.notes,
                tags: $0.tags,
                createdAt: ISO8601DateFormatter().string(from: $0.createdAt)
            )
        }

        if let data = try? JSONEncoder().encode(exportList),
           let jsonString = String(data: data, encoding: .utf8) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(jsonString, forType: .string)
            showToastNotice("Exported \(allItems.count) links as JSON")
        }
    }

    private func showToastNotice(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                toastMessage = nil
            }
        }
    }
}
