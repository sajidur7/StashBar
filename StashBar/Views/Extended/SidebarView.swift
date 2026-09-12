import SwiftUI
import SwiftData

public enum SidebarSelection: Hashable {
    case all
    case pinned
    case recent
    case archived
    case domain(String)
    case tag(String)
}

public struct SidebarView: View {
    @Binding var selection: SidebarSelection
    var items: [StashItem]

    public init(selection: Binding<SidebarSelection>, items: [StashItem]) {
        self._selection = selection
        self.items = items
    }

    private var activeItems: [StashItem] {
        items.filter { !$0.isArchived }
    }

    private var pinnedCount: Int {
        activeItems.filter { $0.isPinned }.count
    }

    private var recentCount: Int {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return activeItems.filter { $0.createdAt >= sevenDaysAgo }.count
    }

    private var archivedCount: Int {
        items.filter { $0.isArchived }.count
    }

    private var domainCounts: [(domain: String, count: Int)] {
        var counts: [String: Int] = [:]
        for item in activeItems {
            counts[item.displayHost, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.map { (domain: $0.key, count: $0.value) }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Section: Collection
                VStack(alignment: .leading, spacing: 3) {
                    Text("COLLECTION")
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .foregroundColor(LinearTheme.ash)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 2)

                    navRow(
                        title: "All Links",
                        icon: "tray",
                        count: activeItems.count,
                        isSelected: selection == .all
                    ) {
                        selection = .all
                    }

                    navRow(
                        title: "Pinned",
                        icon: "pin",
                        count: pinnedCount,
                        isSelected: selection == .pinned
                    ) {
                        selection = .pinned
                    }

                    navRow(
                        title: "Last 7 Days",
                        icon: "clock",
                        count: recentCount,
                        isSelected: selection == .recent
                    ) {
                        selection = .recent
                    }

                    navRow(
                        title: "Archive",
                        icon: "archivebox",
                        count: archivedCount,
                        isSelected: selection == .archived
                    ) {
                        selection = .archived
                    }
                }

                // Section: Top Domains
                if !domainCounts.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TOP DOMAINS")
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(LinearTheme.ash)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 2)

                        ForEach(domainCounts.prefix(6), id: \.domain) { entry in
                            navRow(
                                title: entry.domain,
                                icon: "globe",
                                count: entry.count,
                                isSelected: selection == .domain(entry.domain)
                            ) {
                                selection = .domain(entry.domain)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .frame(minWidth: 175, idealWidth: 195, maxWidth: 215)
        .background(LinearTheme.carbon)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(LinearTheme.graphite)
                .frame(width: 1)
        }
    }

    private func navRow(
        title: String,
        icon: String,
        count: Int,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? LinearTheme.acidLime : LinearTheme.fog)
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 12.5, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? LinearTheme.paper : LinearTheme.mist)
                    .lineLimit(1)

                Spacer()

                Text("\(count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? LinearTheme.acidLime : LinearTheme.ash)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? Color.white.opacity(0.1) : LinearTheme.obsidian)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: LinearTheme.radiusRow, style: .continuous)
                    .fill(isSelected ? LinearTheme.obsidian : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LinearTheme.radiusRow, style: .continuous)
                    .stroke(isSelected ? LinearTheme.graphite : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
