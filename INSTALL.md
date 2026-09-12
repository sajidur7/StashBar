# 🚀 Stash Bar — Installation Guide for Mac

Welcome to **Stash Bar**! Follow these quick steps to get Stash Bar running on your Mac in less than a minute.

---

## 📥 Step 1: Download Stash Bar

1. Download **`StashBar.zip`** from the [GitHub Repository](https://github.com/sajidur7/StashBar) or directly via [Direct Download Link](https://github.com/sajidur7/StashBar/raw/main/StashBar.zip).
2. Double-click `StashBar.zip` to extract **`StashBar.app`**.
3. Drag **`StashBar.app`** into your **`Applications`** folder.

---

## 🔓 Step 2: First-Time Open (macOS Security Check)

Because Stash Bar is distributed directly rather than through the Mac App Store, macOS Gatekeeper may show a notice:
> *"Stash Bar cannot be opened because the developer cannot be verified."*

Choose **Option A** or **Option B** below (you only need to do this once):

### Option A: The 2-Click Method (No Terminal needed)
1. Open your **Applications** folder in Finder.
2. **Right-click** (or `Control + Click`) on **`StashBar.app`**.
3. Click **Open** from the menu.
4. A prompt will appear — click **Open**.
5. *Done! Stash Bar will now open normally with a single click in the future.*

### Option B: The Terminal Command (Instant)
If you prefer using the Terminal:
```bash
xattr -cr /Applications/StashBar.app
```
*(This removes Apple's quarantine flag from the downloaded app).*

---

## ⚡ Step 3: How to Use Stash Bar

Once opened, Stash Bar lives in your macOS **menu bar** at the top right of your screen:

| Action | Shortcut | Description |
| :--- | :--- | :--- |
| **Open Menu Bar Popover** | Click menu bar icon or `⌥ + S` | View recent 10 links, search, and instant clipboard capture |
| **Quick Stash** | `Return (↵)` | Instantly saves any URL copied to your clipboard |
| **Open Extended Window** | `⌘ + E` | Opens full-featured multi-pane canvas window |
| **Search Links** | `⌘ + F` | Filter links by keyword, title, tag, or domain |
| **Open in Browser** | `⌘ + Return` | Launches link in your default browser |
| **Delete Link** | `Delete (⌫)` | Removes link from your collection |

---

## 🛠 System Requirements
- **macOS 14.0 (Sonoma)** or **macOS 15.0+ (Sequoia)**
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
