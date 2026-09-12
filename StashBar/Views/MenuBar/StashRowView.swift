import SwiftUI
import AppKit

public struct StashRowView: View {
    @Bindable var item: StashItem
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @State private var isHovered = false
    @State private var showCopiedFeedback = false

    public init(
        item: StashItem,
        isSelected: Bool = false,
        onSelect: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.item = item
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Linear Acid Lime Selection Indicator
            Capsule()
                .fill(isSelected ? LinearTheme.acidLime : Color.clear)
                .frame(width: 2.5, height: 16)
                .animation(.easeInOut(duration: 0.1), value: isSelected)

            // Favicon or Domain Glyph
            faviconBadge
                .frame(width: 22, height: 22)

            // Title & Host Meta
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                        .foregroundColor(isSelected ? LinearTheme.paper : LinearTheme.mist)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8.5))
                            .foregroundColor(LinearTheme.acidLime)
                    }

                    if !item.tags.isEmpty {
                        ForEach(item.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(LinearTheme.irisViolet)
                                .padding(.horizontal, 4.5)
                                .padding(.vertical, 1)
                                .background(LinearTheme.irisViolet.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        }
                    }
                }

                HStack(spacing: 5) {
                    Text(item.displayHost)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(isSelected ? LinearTheme.acidLime.opacity(0.85) : LinearTheme.fog)

                    Text("•")
                        .font(.system(size: 8))
                        .foregroundColor(LinearTheme.ash)

                    Text(item.timeAgo)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(LinearTheme.ash)
                }
            }

            Spacer(minLength: 4)

            // Copied Toast or Micro-actions
            if showCopiedFeedback {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8.5, weight: .bold))
                    Text("COPIED")
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(LinearTheme.void)
                .padding(.horizontal, 7)
                .padding(.vertical, 2.5)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearTheme.acidLime))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if isHovered || isSelected {
                // Action Buttons (6px Linear ghost buttons)
                HStack(spacing: 4) {
                    // Copy
                    ghostActionButton(icon: "doc.on.doc", tooltip: "Copy URL (↵)") {
                        copyToClipboard()
                    }

                    // Open in Browser
                    ghostActionButton(icon: "arrow.up.right", tooltip: "Open in Browser (⌘↵)") {
                        openInBrowser()
                    }

                    // Pin toggle
                    ghostActionButton(
                        icon: item.isPinned ? "pin.fill" : "pin",
                        tooltip: item.isPinned ? "Unpin" : "Pin link",
                        tint: item.isPinned ? LinearTheme.acidLime : nil
                    ) {
                        item.isPinned.toggle()
                    }

                    // Delete
                    ghostActionButton(icon: "trash", tooltip: "Archive link (⌫)", tint: LinearTheme.coralRed) {
                        onDelete?()
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: LinearTheme.radiusRow, style: .continuous)
                .fill(
                    isSelected ? LinearTheme.obsidian :
                    isHovered ? LinearTheme.obsidian.opacity(0.6) :
                    Color.clear
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusRow, style: .continuous)
                .stroke(
                    isSelected ? LinearTheme.smoke :
                    isHovered ? LinearTheme.graphite :
                    Color.clear,
                    lineWidth: 0.5
                )
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect?()
            copyToClipboard()
        }
    }

    // MARK: - Favicon Badge
    @ViewBuilder
    private var faviconBadge: some View {
        if let data = item.faviconData, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 0.5)
                )
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(LinearTheme.obsidian)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 0.5)
                    )

                Image(systemName: "globe")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(LinearTheme.fog)
            }
        }
    }

    // MARK: - Ghost Action Button (Linear 6px radius)
    private func ghostActionButton(
        icon: String,
        tooltip: String,
        tint: Color? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(tint ?? LinearTheme.fog)
                .frame(width: 22, height: 22)
                .background(LinearTheme.carbon)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url, forType: .string)
        withAnimation(.easeInOut(duration: 0.1)) {
            showCopiedFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.1)) {
                showCopiedFeedback = false
            }
        }
    }

    private func openInBrowser() {
        if let url = URL(string: item.url) {
            NSWorkspace.shared.open(url)
        }
    }
}
