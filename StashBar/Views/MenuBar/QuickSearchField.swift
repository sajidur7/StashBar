import SwiftUI

public struct QuickSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search links, domains, tags..."
    @FocusState private var isFocused: Bool

    public init(text: Binding<String>, placeholder: String = "Search links, domains, tags...") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isFocused ? LinearTheme.acidLime : LinearTheme.fog)
                .font(.system(size: 11.5, weight: .medium))
                .animation(.easeInOut(duration: 0.1), value: isFocused)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(LinearTheme.paper)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundColor(LinearTheme.fog)
                        .padding(3.5)
                        .background(LinearTheme.obsidian)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("⌘F")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundColor(LinearTheme.ash)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1.5)
                    .background(LinearTheme.obsidian)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: LinearTheme.radiusInput, style: .continuous)
                .fill(LinearTheme.carbon)
        )
        .overlay(
            RoundedRectangle(cornerRadius: LinearTheme.radiusInput, style: .continuous)
                .stroke(
                    isFocused ? LinearTheme.acidLime.opacity(0.8) : LinearTheme.graphite,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.1), value: isFocused)
    }
}
