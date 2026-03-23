# LeetBar

LeetBar is a macOS menu bar app that shows LeetCode solved counts and streak metrics.

## Download / Install (one command)

Run this command (replace `owner/repo` with your GitHub repo):

```bash
curl -fsSL https://raw.githubusercontent.com/owner/repo/main/scripts/install.sh | LEETBAR_REPO=owner/repo bash
```

This follows the standard macOS menu bar app flow:
1. Fetch latest GitHub release.
2. Download `LeetBar-macOS.zip`.
3. Install `LeetBar.app` into `/Applications`.
4. Remove quarantine metadata.
5. Launch the app.

Notes:
- Release artifacts are generated automatically when a tag like `v1.2.0` is pushed.
- The release includes `SHA256SUMS.txt` for integrity verification.

## Create a downloadable build locally

```bash
chmod +x scripts/package-macos.sh
./scripts/package-macos.sh
```

Artifacts are written to:
- `dist/LeetBar-macOS.zip`
- `dist/SHA256SUMS.txt`

## Development

```bash
swift build
swift run
```
