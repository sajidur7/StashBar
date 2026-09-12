import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Linear Design System Tokens (Midnight Precision Instrument)
// Dark command center built on near-black surfaces (#08090a), paper-white type (#ffffff),
// hairline borders (#23252a), precision 6px/12px radii, and an electric Acid Lime (#e4f222) CTA.
public enum LinearTheme {
    // Surfaces
    public static let void = Color(hex: "08090a")            // Void: Page canvas, full-bleed backgrounds
    public static let carbon = Color(hex: "0f1011")          // Carbon: Card surfaces, command panels, navigation bars
    public static let obsidian = Color(hex: "161718")        // Obsidian: Elevated surfaces, nested card panels
    public static let graphite = Color(hex: "23252a")        // Graphite: Hairline borders, dividers, ghost button outlines
    public static let smoke = Color(hex: "383b3f")           // Smoke: Higher contrast hairline borders & section separators
    public static let slate = Color(hex: "23252a")           // Slate: Interactive surface tint, border-adjacent backgrounds

    // Grayscale Typography
    public static let paper = Color(hex: "ffffff")           // Paper: Primary headings, hero type, max-contrast text
    public static let bone = Color(hex: "e5e5e6")            // Bone: Near-white surface fills, high-contrast button text
    public static let mist = Color(hex: "d0d6e0")            // Mist: Secondary headings, body text on dark surfaces
    public static let fog = Color(hex: "8a8f98")             // Fog: Tertiary text, placeholder copy, icon fills
    public static let ash = Color(hex: "62666d")             // Ash: Muted metadata, inactive icons, captions

    // Chromatic Accents
    public static let acidLime = Color(hex: "e4f222")        // Acid Lime: Single primary action CTA — electric flashlight
    public static let acidLimeHover = Color(hex: "d3e01a")   // Acid Lime pressed/hover
    public static let pulseGreen = Color(hex: "27a644")      // Pulse Green: Supporting green accent, clean verification
    public static let coralRed = Color(hex: "eb5757")        // Coral Red: Soft red accent, destructive/warning actions
    public static let signalTeal = Color(hex: "02b8cc")      // Signal Teal: Decorative accent, info icon fills
    public static let irisViolet = Color(hex: "6366f1")      // Iris Violet: Soft chromatic punctuation on tags and labels
    public static let lavender = Color(hex: "8b5cf6")        // Lavender: Secondary tag fills, category indicators

    // Linear Precision Radii Vocabulary (Cards: 12px, Inputs/Buttons: 6px, Badges: 4px, Pills: 9999px)
    public static let radiusCard: CGFloat = 12
    public static let radiusRow: CGFloat = 6
    public static let radiusButton: CGFloat = 6
    public static let radiusInput: CGFloat = 6
    public static let radiusBadge: CGFloat = 4
    public static let radiusPill: CGFloat = 9999

    // Aliases to seamlessly support existing theme references
    public static var pageCanvas: Color { void }
    public static var cardSurface: Color { carbon }
    public static var elevatedSurface: Color { obsidian }
    public static var subtleSurface: Color { obsidian }

    public static var borderSubtle: Color { graphite }
    public static var borderCard: Color { graphite }
    public static var borderActive: Color { acidLime }
    public static var glowRing: Color { acidLime.opacity(0.12) }

    public static var inkBlack: Color { paper }
    public static var paperWhite: Color { void }
    public static var signalBlue: Color { acidLime }
    public static var appleBlue: Color { acidLime }
    public static var linkBlue: Color { mist }

    public static var concrete: Color { obsidian }
    public static var pebble: Color { graphite }
    public static var sterling: Color { fog }
    public static var spaceBlack: Color { paper }
    public static var graphiteColor: Color { graphite }

    public static var textPrimary: Color { paper }
    public static var textSecondary: Color { mist }
    public static var textMuted: Color { fog }
    public static var textCaption: Color { ash }

    public static var primaryCtaBg: Color { acidLime }
    public static var primaryCtaText: Color { void }
    public static var primaryCtaHover: Color { acidLimeHover }
    public static var selectionIndicator: Color { acidLime }
}

// Backward-compatibility aliases
public typealias AppleTheme = LinearTheme
public typealias PortalTheme = LinearTheme
public typealias AirTheme = LinearTheme

// MARK: - StashBar Custom Vector Icon (Exact Lucide external-link SVG)
public struct StashBarIcon: View {
    var size: CGFloat = 16
    var color: Color = LinearTheme.acidLime
    var lineWidth: CGFloat = 2

    public init(size: CGFloat = 16, color: Color = LinearTheme.acidLime, lineWidth: CGFloat = 2) {
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24.0

            // Path 1: M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6
            var path1 = Path()
            path1.move(to: CGPoint(x: 18 * scale, y: 13 * scale))
            path1.addLine(to: CGPoint(x: 18 * scale, y: 19 * scale))
            path1.addArc(tangent1End: CGPoint(x: 18 * scale, y: 21 * scale), tangent2End: CGPoint(x: 16 * scale, y: 21 * scale), radius: 2 * scale)
            path1.addLine(to: CGPoint(x: 5 * scale, y: 21 * scale))
            path1.addArc(tangent1End: CGPoint(x: 3 * scale, y: 21 * scale), tangent2End: CGPoint(x: 3 * scale, y: 19 * scale), radius: 2 * scale)
            path1.addLine(to: CGPoint(x: 3 * scale, y: 8 * scale))
            path1.addArc(tangent1End: CGPoint(x: 3 * scale, y: 6 * scale), tangent2End: CGPoint(x: 5 * scale, y: 6 * scale), radius: 2 * scale)
            path1.addLine(to: CGPoint(x: 11 * scale, y: 6 * scale))

            // Path 2: M10 14 21 3
            var path2 = Path()
            path2.move(to: CGPoint(x: 10 * scale, y: 14 * scale))
            path2.addLine(to: CGPoint(x: 21 * scale, y: 3 * scale))

            // Path 3: M15 3h6v6
            var path3 = Path()
            path3.move(to: CGPoint(x: 15 * scale, y: 3 * scale))
            path3.addLine(to: CGPoint(x: 21 * scale, y: 3 * scale))
            path3.addLine(to: CGPoint(x: 21 * scale, y: 9 * scale))

            let strokeStyle = StrokeStyle(lineWidth: lineWidth * scale, lineCap: .round, lineJoin: .round)
            context.stroke(path1, with: .color(color), style: strokeStyle)
            context.stroke(path2, with: .color(color), style: strokeStyle)
            context.stroke(path3, with: .color(color), style: strokeStyle)
        }
        .frame(width: size, height: size)
    }

    #if canImport(AppKit)
    public static var menuBarImage: NSImage {
        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size, flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            let scale: CGFloat = 18.0 / 24.0

            ctx.saveGState()
            ctx.translateBy(x: 0, y: 18)
            ctx.scaleBy(x: scale, y: -scale)

            let cgPath = CGMutablePath()
            // Path 1: M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6
            cgPath.move(to: CGPoint(x: 18, y: 13))
            cgPath.addLine(to: CGPoint(x: 18, y: 19))
            cgPath.addArc(tangent1End: CGPoint(x: 18, y: 21), tangent2End: CGPoint(x: 16, y: 21), radius: 2)
            cgPath.addLine(to: CGPoint(x: 5, y: 21))
            cgPath.addArc(tangent1End: CGPoint(x: 3, y: 21), tangent2End: CGPoint(x: 3, y: 19), radius: 2)
            cgPath.addLine(to: CGPoint(x: 3, y: 8))
            cgPath.addArc(tangent1End: CGPoint(x: 3, y: 6), tangent2End: CGPoint(x: 5, y: 6), radius: 2)
            cgPath.addLine(to: CGPoint(x: 11, y: 6))

            // Path 2: M10 14 21 3
            cgPath.move(to: CGPoint(x: 10, y: 14))
            cgPath.addLine(to: CGPoint(x: 21, y: 3))

            // Path 3: M15 3h6v6
            cgPath.move(to: CGPoint(x: 15, y: 3))
            cgPath.addLine(to: CGPoint(x: 21, y: 3))
            cgPath.addLine(to: CGPoint(x: 21, y: 9))

            ctx.addPath(cgPath)
            ctx.setStrokeColor(NSColor.black.cgColor)
            ctx.setLineWidth(2)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            ctx.strokePath()

            ctx.restoreGState()
            return true
        }
        img.isTemplate = true
        return img
    }
    #endif
}

// MARK: - Color Hex Initializer
extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Berkeley Mono Keyboard Shortcut Pill (Linear style: 4px radius, #161718 fill, #383b3f border)
public struct KbdBadge: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .medium, design: .monospaced))
            .foregroundColor(LinearTheme.fog)
            .padding(.horizontal, 5.5)
            .padding(.vertical, 2)
            .background(LinearTheme.obsidian)
            .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusBadge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LinearTheme.radiusBadge, style: .continuous)
                    .stroke(LinearTheme.graphite, lineWidth: 1)
            )
    }
}

// MARK: - Linear Dynamic 9999px Pill Filter
public struct DynamicPill: View {
    let title: String
    var count: Int? = nil
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    public init(
        title: String,
        count: Int? = nil,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.count = count
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isSelected ? LinearTheme.paper : LinearTheme.fog)
                }

                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? LinearTheme.paper : LinearTheme.mist)

                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.white.opacity(0.12) : LinearTheme.obsidian)
                        .foregroundColor(isSelected ? LinearTheme.paper : LinearTheme.ash)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4.5)
            .background(
                Capsule()
                    .fill(
                        isSelected ? Color.white.opacity(0.08) :
                        isHovered ? Color.white.opacity(0.04) :
                        Color.clear
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? LinearTheme.smoke :
                        isHovered ? LinearTheme.graphite :
                        Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Linear Button Styles (6px radius, precision hairline borders)
public struct GhostButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = LinearTheme.radiusButton
    var isProminent: Bool = false

    public init(cornerRadius: CGFloat = LinearTheme.radiusButton, isProminent: Bool = false) {
        self.cornerRadius = cornerRadius
        self.isProminent = isProminent
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12.5, weight: isProminent ? .semibold : .medium))
            .foregroundColor(isProminent ? LinearTheme.void : LinearTheme.mist)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        isProminent ? (configuration.isPressed ? LinearTheme.acidLimeHover : LinearTheme.acidLime) :
                        (configuration.isPressed ? LinearTheme.obsidian : LinearTheme.carbon)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        isProminent ? Color.clear : LinearTheme.graphite,
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Linear Primary CTA Button (Acid Lime #e4f222, 6px radius, Inter 14px/510)
public struct LinearPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(LinearTheme.void)
            .padding(.horizontal, 14)
            .padding(.vertical, 6.5)
            .background(
                RoundedRectangle(cornerRadius: LinearTheme.radiusButton, style: .continuous)
                    .fill(configuration.isPressed ? LinearTheme.acidLimeHover : LinearTheme.acidLime)
            )
    }
}

// MARK: - Linear Status Badge (4px radius, Inter 12px, soft chromatic variant)
public struct LinearBadge: View {
    let text: String
    var color: Color = LinearTheme.fog
    var bg: Color = Color.white.opacity(0.05)

    public init(_ text: String, color: Color = LinearTheme.fog, bg: Color = Color.white.opacity(0.05)) {
        self.text = text
        self.color = color
        self.bg = bg
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2.5)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: LinearTheme.radiusBadge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LinearTheme.radiusBadge, style: .continuous)
                    .stroke(color.opacity(0.25), lineWidth: 0.5)
            )
    }
}
