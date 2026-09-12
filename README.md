# Stash Bar (⌥ + S)

> **A native, friction-free macOS menu bar link stasher & quick-clipboard vault.**  
> Built for speed with SwiftUI, SwiftData, and the Linear midnight precision design system.

---

## 📥 Quick Install & Download

- **Direct Download:** Download [`StashBar.zip`](./StashBar.zip)
- **Step-by-step Guide:** See [**`INSTALL.md`**](./INSTALL.md) for 30-second setup and macOS Gatekeeper bypass instructions.

```bash
# Optional 1-liner to bypass macOS Gatekeeper after moving to Applications:
xattr -cr /Applications/StashBar.app
```

---

## ✦ What is Stash Bar?

**Stash Bar** lives quietly in your macOS menu bar. Instead of heavy web dashboards or clumsy browser bookmarks, Stash Bar gives you instantaneous one-click URL capture directly from your clipboard, resolves website metadata (titles, favicons, OpenGraph previews) in the background, and provides two distinct interfaces:

1. **Compact Popover (`⌥S`):** Quick access to your most recent links, automatic clipboard URL detection, and keyboard-first search.
2. **Extended Canvas (`⌘E`):** A full-width Linear midnight command center to search, inspect previews, categorize with tags, filter domains, and export your stash.

---

## ⚡ Key Features

- **Menu Bar Native (`MenuBarExtra`):** Zero dock clutter, lightweight footprint, instant invocation.
- **Smart Clipboard Auto-Detection:** Automatically spots URLs on the system clipboard (`NSPasteboard`) upon popover display with an inline prompt: `Press Enter to Stash`.
- **Clean URL Engine:** Strips tracking parameters (`utm_*`, `fbclid`, `gclid`, `ref`, `si`, `igshid`, etc.) on the fly while preserving legitimate query parameters.
- **Background Metadata Resolution:** Asynchronously pulls title, host domain, favicon, and OpenGraph preview without freezing the UI.
- **Linear Midnight Precision Aesthetic:** Built on `#08090a` Void canvas, `#0f1011` Carbon cards, hairline borders, and electric **Acid Lime (`#e4f222`)** action CTAs.
- **Keyboard-First Navigation:**
  - `Enter` → Copy URL & close popover (or stash detected clipboard URL)
  - `⌘ + Enter` → Open URL directly in default browser
  - `⌘ + E` → Expand to full multi-column Canvas
  - `Delete` → Archive/delete link
- **Local & Offline First:** Powered by **SwiftData** for instant full-text filtering and zero latency.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `⌥ + S` | Toggle Stash Bar menu popover |
| `⌘ + E` | Open Extended Canvas window |
| `↵ (Enter)` | Copy URL or Stash clipboard link |
| `⌘ + ↵` | Open link in default browser |
| `⌘ + F` | Focus search bar |
| `⌫ (Delete)` | Delete / Archive link |

---

## 🛠 Tech Stack

- **Target OS:** macOS 14.0 (Sonoma) or macOS 15.0+ (Sequoia)
- **UI Framework:** SwiftUI (`MenuBarExtra`, `WindowGroup`, custom Linear design system)
- **Data Persistence:** SwiftData
- **Network / Scraping:** `URLSession` stream parsing (fetches first 50KB for `<head>` OG metadata)
- **Engineered with:** Antigravity AI

---

## 🔨 Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/StashBar.git
cd StashBar

# Run automated unit tests
swift test

# Build release .app bundle
./scripts/build_app.sh

# Launch the app
open build/StashBar.app
```

---

## 📄 License

MIT License. Copyright © 2026 Antigravity AI. All rights reserved.
