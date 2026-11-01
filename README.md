# zcode-rs preview builds

Preview builds of the zcode terminal client, for testing before they reach the official package. They contain unfinished work.

```sh
curl -fsSL https://raw.githubusercontent.com/Linyxus/zcode-rs-preview-releases/main/install.sh | sh
```

This installs `zcode-rs` into `~/.local/bin`, for macOS arm64, Linux x64 and Linux arm64. Your existing `zcode` stays as it is.

To update, run the same command again. `zcode-rs update` does not work on these builds.

To install a certain version, set `ZCODE_RS_VERSION`. To install somewhere else, set `ZCODE_RS_INSTALL_DIR`:

```sh
curl -fsSL https://raw.githubusercontent.com/Linyxus/zcode-rs-preview-releases/main/install.sh | ZCODE_RS_VERSION=0.1.90 ZCODE_RS_INSTALL_DIR=~/bin sh
```

Each release says which commit it was built from, in its notes and in `build.json`.

**A preview build uses the same `~/.zcode` as the official client**, so a bug in a preview can affect your real sessions.
