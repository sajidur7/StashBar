import Foundation
import SwiftData

@Model
public final class StashItem {
    @Attribute(.unique) public var id: UUID
    public var url: String
    public var originalUrl: String
    public var title: String
    public var host: String
    public var itemDescription: String?
    public var faviconUrl: String?
    public var faviconData: Data?
    public var ogImageUrl: String?
    public var ogImageData: Data?
    public var createdAt: Date
    public var updatedAt: Date
    public var isPinned: Bool
    public var isArchived: Bool
    public var tags: [String]
    public var notes: String

    public init(
        id: UUID = UUID(),
        url: String,
        originalUrl: String? = nil,
        title: String? = nil,
        host: String? = nil,
        itemDescription: String? = nil,
        faviconUrl: String? = nil,
        faviconData: Data? = nil,
        ogImageUrl: String? = nil,
        ogImageData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        isArchived: Bool = false,
        tags: [String] = [],
        notes: String = ""
    ) {
        self.id = id
        self.url = url
        self.originalUrl = originalUrl ?? url
        
        let resolvedHost: String
        if let host = host, !host.isEmpty {
            resolvedHost = host
        } else if let parsed = URL(string: url)?.host {
            resolvedHost = parsed
        } else {
            resolvedHost = "unknown"
        }
        self.host = resolvedHost

        if let title = title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.title = title
        } else {
            self.title = resolvedHost
        }

        self.itemDescription = itemDescription
        self.faviconUrl = faviconUrl
        self.faviconData = faviconData
        self.ogImageUrl = ogImageUrl
        self.ogImageData = ogImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.tags = tags
        self.notes = notes
    }

    public var displayHost: String {
        if host.lowercased().hasPrefix("www.") {
            return String(host.dropFirst(4))
        }
        return host
    }

    public var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
