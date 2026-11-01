#!/bin/sh
# Installs a preview build of zcode-rs. docs/specs/rust-cli/preview-release.md section 5.
# ASCII only: bash 3.2 under the C locale reads multi-byte characters into variable names.
set -eu

repo_url="${ZCODE_RS_RELEASES_URL:-https://github.com/Linyxus/zcode-rs-preview-releases/releases}"
install_dir="${ZCODE_RS_INSTALL_DIR:-$HOME/.local/bin}"
version="${ZCODE_RS_VERSION:-}"

fail() {
  echo "zcode-rs install: $1" >&2
  exit 1
}

os=$(uname -s)
arch=$(uname -m)
# A shell under Rosetta reports x86_64 on an arm64 Mac.
if [ "$os" = Darwin ] && [ "$arch" = x86_64 ] &&
  [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
  arch=arm64
fi
case "$os-$arch" in
  Darwin-arm64) target=darwin-arm64 ;;
  Linux-x86_64 | Linux-amd64) target=linux-x64 ;;
  Linux-aarch64 | Linux-arm64) target=linux-arm64 ;;
  *) fail "no preview build for $os $arch (there are builds for macOS arm64, Linux x64 and Linux arm64)" ;;
esac

if [ -n "$version" ]; then
  version=${version#v}
  base="$repo_url/download/v$version"
else
  base="$repo_url/latest/download"
fi
file="zcode-rs-$target.gz"

mkdir -p "$install_dir"
work=$(mktemp -d "$install_dir/.zcode-rs-install.XXXXXX")
trap 'rm -rf "$work"' EXIT

echo "Downloading $file"
curl -fsSL "$base/$file" -o "$work/$file" || fail "could not download $base/$file"
curl -fsSL "$base/SHA256SUMS" -o "$work/SHA256SUMS" || fail "could not download $base/SHA256SUMS"

expected=$(awk -v name="$file" '$2 == name { print $1 }' "$work/SHA256SUMS")
[ -n "$expected" ] || fail "SHA256SUMS has no line for $file"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$work/$file" | awk '{ print $1 }')
else
  actual=$(shasum -a 256 "$work/$file" | awk '{ print $1 }')
fi
[ "$actual" = "$expected" ] || fail "the checksum of $file does not match; nothing was installed"

gunzip -c "$work/$file" >"$work/zcode-rs"
chmod 755 "$work/zcode-rs"
mv -f "$work/zcode-rs" "$install_dir/zcode-rs"

echo "Installed $install_dir/zcode-rs"
"$install_dir/zcode-rs" --version || true
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) echo "Add $install_dir to your PATH to run zcode-rs." ;;
esac
