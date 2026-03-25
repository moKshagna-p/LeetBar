# LeetBar

Tiny macOS menu bar app for LeetCode stats. It shows solved counts, streaks, and a compact dashboard from your menu bar without a Dock app.

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
