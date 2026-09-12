import SwiftUI
import AppKit
import SwiftData

public struct LinkDetailView: View {
    @Bindable var item: StashItem
    @Environment(\.modelContext) private var modelContext

    @State private var newTagText: String = ""
    @State private var isRefreshing: Bool = false
    @State private var showCopiedBanner: String? = nil

    public init(item: StashItem) {
        self.item = item
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Top Header Precision Card
                headerCard

                // OpenGraph Preview Card
                ogPreviewCard

                // Personal Notes Floating Surface
                notesSection

                // Dynamic Tag Pills Section
                tagsSection

                // Meta Info Footer
                metaInfoSection
            }
            .padding(16)
        }
        .background(LinearTheme.carbon)
        .overlay(alignment: .top) {
            if let message = showCopiedBanner {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundColor(LinearTheme.void)
                    Text(message)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(LinearTheme.void)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearTheme.acidLime))
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                // Favicon
                faviconBadge
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    TextField("Title", text: $item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(LinearTheme.paper)
                        .textFieldStyle(.plain)

                    HStack(spacing: 6) {
                        Text(item.displayHost)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(LinearTheme.acidLime)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LinearTheme.acidLime.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

                        Text("•")
                            .font(.system(size: 8))
                            .foregroundColor(LinearTheme.ash)

                        Text("Stashed \(item.timeAgo)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(LinearTheme.fog)
                    }
                }

                Spacer()

                // Pin Button
                ghostActionButton(
                    icon: item.isPinned ? "pin.fill" : "pin",
                    tooltip: item.isPinned ? "Unpin" : "Pin link",
                    tint: item.isPinned ? LinearTheme.acidLime : nil
                ) {
                    item.isPinned.toggle()
                }

                // Archive / Restore
                ghostActionButton(
                    icon: item.isArchived ? "tray.and.arrow.up" : "archivebox",
                    tooltip: item.isArchived ? "Restore link" : "Archive link"
                ) {
                    item.isArchived.toggle()
                }
            }

            // URL Row & Action Buttons
            HStack(spacing: 8) {
                Text(item.url)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(LinearTheme.mist)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(LinearTheme.obsidian)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 1)
                    )

                Spacer()

                Button(action: copyCleanUrl) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 9.5))
                        Text("Copy")
                            .font(.system(size: 11.5, weight: .medium))
                    }
                }
                .buttonStyle(GhostButtonStyle(cornerRadius: LinearTheme.radiusButton))

                Button(action: openInBrowser) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9.5))
                        Text("Open")
                            .font(.system(size: 11.5, weight: .semibold))
                    }
                }
                .buttonStyle(GhostButtonStyle(cornerRadius: LinearTheme.radiusButton, isProminent: true))
            }
        }
        .padding(14)
        .background(LinearTheme.obsidian)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Favicon Badge
    @ViewBuilder
    private var faviconBadge: some View {
        if let data = item.faviconData, let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 0.5)
                )
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(LinearTheme.obsidian)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(LinearTheme.graphite, lineWidth: 0.5)
                    )

                Image(systemName: "globe")
                    .font(.system(size: 14))
                    .foregroundColor(LinearTheme.acidLime)
            }
        }
    }

    // MARK: - OpenGraph Preview Card
    private var ogPreviewCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imgData = item.ogImageData, let nsImage = NSImage(data: imgData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 180)
                    .clipped()
                    .overlay(
                        Rectangle()
                            .stroke(LinearTheme.graphite, lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("METADATA // OPENGRAPH")
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .foregroundColor(LinearTheme.ash)

                    Spacer()

                    Button(action: refreshMetadata) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 9.5))
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                            Text("Re-fetch")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(LinearTheme.acidLime)
                    }
                    .buttonStyle(.plain)
                }

                if let desc = item.itemDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12.5, weight: .regular))
                        .foregroundColor(LinearTheme.mist)
                        .lineSpacing(2.5)
                        .lineLimit(4)
                } else {
                    Text("No summary resolved yet.")
                        .font(.system(size: 11.5))
                        .foregroundColor(LinearTheme.fog)
                }
            }
            .padding(12)
        }
        .background(LinearTheme.obsidian)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "note.text")
                    .font(.system(size: 10.5))
                    .foregroundColor(LinearTheme.fog)
                Text("Notes & Annotations")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(LinearTheme.paper)
            }

            TextEditor(text: $item.notes)
                .font(.system(size: 12.5, design: .monospaced))
                .foregroundColor(LinearTheme.mist)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 70)
                .padding(8)
                .background(LinearTheme.obsidian)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )
        }
    }

    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 11))
                        .foregroundColor(LinearTheme.irisViolet)
                    Text("Tags & Labels")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(LinearTheme.paper)
                }

                Spacer()

                if !item.tags.isEmpty {
                    Text("\(item.tags.count) tag\(item.tags.count > 1 ? "s" : "")")
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundColor(LinearTheme.ash)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                // Existing Tags Row
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(item.tags, id: \.self) { tag in
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(LinearTheme.irisViolet)
                                        .frame(width: 5, height: 5)

                                    Text(tag)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(LinearTheme.paper)

                                    Button(action: { removeTag(tag) }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(LinearTheme.fog)
                                            .padding(2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4.5)
                                .background(LinearTheme.obsidian)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(LinearTheme.irisViolet.opacity(0.35), lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                // Add Tag Full-Width Input Field
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(LinearTheme.fog)

                    TextField("Add a tag (press Return to save)...", text: $newTagText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12.5))
                        .foregroundColor(LinearTheme.paper)
                        .onSubmit(addTag)

                    if !newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: addTag) {
                            Text("Add Tag")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(LinearTheme.void)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(LinearTheme.acidLime))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(LinearTheme.obsidian)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )

                // Quick Suggested Tags
                let suggestions = ["design", "development", "reading", "tools", "inspo"].filter { !item.tags.contains($0) }
                if !suggestions.isEmpty {
                    HStack(spacing: 6) {
                        Text("Quick add:")
                            .font(.system(size: 10.5, design: .monospaced))
                            .foregroundColor(LinearTheme.ash)

                        ForEach(suggestions.prefix(4), id: \.self) { suggestion in
                            Button(action: {
                                if !item.tags.contains(suggestion) {
                                    item.tags.append(suggestion)
                                    try? modelContext.save()
                                }
                            }) {
                                HStack(spacing: 3) {
                                    Text("+")
                                        .font(.system(size: 9, weight: .bold))
                                    Text(suggestion)
                                        .font(.system(size: 10.5, weight: .medium))
                                }
                                .foregroundColor(LinearTheme.fog)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(LinearTheme.carbon)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .stroke(LinearTheme.graphite, lineWidth: 0.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding(12)
        .background(LinearTheme.obsidian.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(LinearTheme.graphite, lineWidth: 1)
        )
    }



    // MARK: - Meta Info
    private var metaInfoSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CREATED")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundColor(LinearTheme.ash)
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(LinearTheme.mist)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("HOST")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundColor(LinearTheme.ash)
                Text(item.host)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(LinearTheme.mist)
            }

            Spacer()

            Button(action: deleteItem) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 9.5))
                    Text("Delete")
                        .font(.system(size: 11))
                }
                .foregroundColor(LinearTheme.coralRed)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(LinearTheme.coralRed.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(LinearTheme.coralRed.opacity(0.25), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    // MARK: - Ghost Action Button Helper
    private func ghostActionButton(
        icon: String,
        tooltip: String,
        tint: Color? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(tint ?? LinearTheme.fog)
                .frame(width: 24, height: 24)
                .background(LinearTheme.obsidian)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(LinearTheme.graphite, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }

    // MARK: - Actions
    private func copyCleanUrl() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url, forType: .string)
        notifyCopied("Copied clean URL!")
    }

    private func openInBrowser() {
        if let url = URL(string: item.url) {
            NSWorkspace.shared.open(url)
        }
    }

    private func addTag() {
        let tag = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty && !item.tags.contains(tag) else { return }
        item.tags.append(tag)
        newTagText = ""
        try? modelContext.save()
    }

    private func removeTag(_ tag: String) {
        item.tags.removeAll { $0 == tag }
        try? modelContext.save()
    }

    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
    }

    private func refreshMetadata() {
        guard !isRefreshing else { return }
        isRefreshing = true
        Task {
            await MetadataParser.resolveMetadata(for: item.id, urlString: item.url, context: modelContext)
            await MainActor.run {
                isRefreshing = false
                notifyCopied("Refreshed metadata")
            }
        }
    }

    private func notifyCopied(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            showCopiedBanner = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.1)) {
                showCopiedBanner = nil
            }
        }
    }
}
