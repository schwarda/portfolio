#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_CACHE_DIR="$ROOT_DIR/.vercel/flutter-sdk"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.29.2}"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="$(command -v flutter)"
else
  FLUTTER_BIN="$FLUTTER_CACHE_DIR/bin/flutter"
fi

if [ ! -x "$FLUTTER_BIN" ]; then
  mkdir -p "$(dirname "$FLUTTER_CACHE_DIR")"
  ARCHIVE_PATH="/tmp/flutter_linux_${FLUTTER_VERSION}_stable.tar.xz"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

  curl -fsSL "$FLUTTER_URL" -o "$ARCHIVE_PATH"
  rm -rf "$FLUTTER_CACHE_DIR"
  tar -xJf "$ARCHIVE_PATH" -C "$(dirname "$FLUTTER_CACHE_DIR")"
  mv "$(dirname "$FLUTTER_CACHE_DIR")/flutter" "$FLUTTER_CACHE_DIR"
  FLUTTER_BIN="$FLUTTER_CACHE_DIR/bin/flutter"
fi

"$FLUTTER_BIN" --version
"$FLUTTER_BIN" pub get

build_args=(--release)

if [ -n "${TURNSTILE_SITE_KEY:-}" ]; then
  build_args+=("--dart-define=TURNSTILE_SITE_KEY=${TURNSTILE_SITE_KEY}")
fi

if [ -n "${CHAT_API_URL:-}" ]; then
  build_args+=("--dart-define=CHAT_API_URL=${CHAT_API_URL}")
fi

"$FLUTTER_BIN" build web "${build_args[@]}"
