import Foundation

public struct URLSanitizer {
    /// Set of common marketing, analytics, and social tracking query parameter keys (lowercased).
    public static let trackingQueryParameters: Set<String> = [
        // Google / Universal UTM
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "utm_id", "utm_name", "utm_referrer", "utm_reader", "utm_viz_id", "utm_pubreferrer",
        // Meta / Facebook / Instagram
        "fbclid", "igshid", "share_id", "mid",
        // Google Ads & Analytics
        "gclid", "gclsrc", "dclid", "wbraid", "gbraid", "gad_source", "gadid",
        // Microsoft / Bing
        "msclkid",
        // Twitter / X
        "twclid",
        // Email & CRM (Mailchimp, HubSpot, Marketo)
        "mc_cid", "mc_eid", "_hsenc", "_hsmi", "mkt_tok",
        // Social Media & Share Trackers
        "si", // Spotify & YouTube share id
        "ref", "ref_src", "ref_url", "source", "feature",
        // Other Ad & Affiliate Networks
        "wickedid", "yclid", "trk", "spm", "zanpid"
    ]

    /// Sanitizes the provided URL string by removing tracking query parameters and formatting cleanly.
    /// Returns nil if the string cannot be parsed into a valid HTTP/HTTPS URL.
    public static func sanitize(_ urlString: String) -> String? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Automatically prepend https:// if protocol is omitted but looks like a domain
        var candidate = trimmed
        if !candidate.lowercased().hasPrefix("http://") && !candidate.lowercased().hasPrefix("https://") {
            // Check if looks like a host (contains a dot and no whitespace)
            if candidate.contains(".") && !candidate.contains(" ") {
                candidate = "https://" + candidate
            } else {
                return nil
            }
        }

        guard let components = URLComponents(string: candidate),
              let host = components.host, !host.isEmpty else {
            return nil
        }

        var cleaned = components
        
        // Normalize scheme and host to lowercase
        cleaned.scheme = components.scheme?.lowercased()
        cleaned.host = components.host?.lowercased()

        // Filter query items
        if let queryItems = components.queryItems, !queryItems.isEmpty {
            let filteredItems = queryItems.filter { item in
                let key = item.name.lowercased()
                return !trackingQueryParameters.contains(key) && !key.hasPrefix("utm_")
            }

            cleaned.queryItems = filteredItems.isEmpty ? nil : filteredItems
        }

        // Clean trailing slash if path is only "/" and there are no query/fragment
        if cleaned.path == "/" && cleaned.query == nil && cleaned.fragment == nil {
            cleaned.path = ""
        }

        return cleaned.url?.absoluteString
    }

    /// Tests whether a given string is a valid URL candidate.
    public static func isValidUrl(_ candidate: String) -> Bool {
        return sanitize(candidate) != nil
    }

    /// Extracts clean host for display (removes leading www.).
    public static func cleanHost(from urlString: String) -> String? {
        guard let url = URL(string: urlString), let host = url.host else { return nil }
        if host.lowercased().hasPrefix("www.") {
            return String(host.dropFirst(4))
        }
        return host
    }
}
