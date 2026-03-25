# LeetBar

Tiny macOS menu bar app for LeetCode stats. It shows solved counts, streaks, and a compact dashboard from your menu bar without a Dock app.

## Peview
<img width="445" height="589" alt="Screenshot 2026-03-25 at 9 39 49 PM" src="https://github.com/user-attachments/assets/6ef9e865-1883-4a79-a837-95fb2aa1bdeb" />
<img width="495" height="235" alt="Screenshot 2026-03-25 at 9 40 06 PM" src="https://github.com/user-attachments/assets/a388459c-95be-45be-9c35-0bd36d17dfba" />

## Install

### Requirements

- macOS 14+

### GitHub Releases

Download the latest app build from GitHub Releases:

https://github.com/moKshagna-p/LeetBar/releases

From the **Assets** list, download `LeetBar-<version>.zip` (not GitHub's auto-generated `Source code (zip)`).
Unzip it, then open `LeetBar.app` directly from Downloads or move it to `/Applications`.

## Build From Source

```bash
swift build -c release
swift run
```

If you prefer Xcode, open the package and run the `LeetBar` target directly.

## Development Notes

- The app is built as a Swift Package.
- The packaged app bundle runs as a menu bar app via `LSUIElement`.
- No install or release shell scripts are required.
