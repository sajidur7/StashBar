# 🚀 Stash Bar — Installation Guide for Mac

Welcome to **Stash Bar**! Follow these quick steps to get Stash Bar running on your Mac in less than a minute.

---

## 📥 Step 1: Download Stash Bar

1. Download **`StashBar.zip`** from the [GitHub Repository](https://github.com/sajidur7/StashBar) or directly via [Direct Download Link](https://github.com/sajidur7/StashBar/raw/main/StashBar.zip).
2. Double-click `StashBar.zip` to extract **`StashBar.app`**.
3. Drag **`StashBar.app`** into your **`Applications`** folder.

---

## 🔓 Step 2: First-Time Open (macOS Security Check)

Because Stash Bar is an open-source indie app distributed outside the Mac App Store, macOS Gatekeeper may show:
> **"StashBar" Not Opened**  
> *Apple could not verify "StashBar" is free of malware that may harm your Mac or compromise your privacy.*  
> `[Done]` `[Move to Bin]`

Choose **Option A** (System Settings) or **Option B** (Terminal) — you only need to do this **once**:

### Option A: macOS System Settings (Recommended, No Terminal needed)
1. On the warning popup, click **Done** (do NOT click Move to Bin).
2. Open **System Settings** (click  Apple menu in top-left > **System Settings**).
3. In the sidebar, click **Privacy & Security**.
4. Scroll down to the **Security** section.
5. You will see a message:
   > *"StashBar" was blocked from use because it is not from an identified developer.*
6. Click the button: **Open Anyway**.
7. Enter your Mac password or Touch ID when prompted, and click **Open**.
8. *Done! Stash Bar will now open normally with a single click.*

### Option B: The Terminal Command (Instant 1-Liner)
If you prefer Terminal, open the Terminal app and run:
```bash
xattr -cr /Applications/StashBar.app
```
*(Or if it is in your Downloads folder: `xattr -cr ~/Downloads/StashBar.app`)*

This immediately clears Apple's quarantine flag and lets Stash Bar launch immediately.

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
