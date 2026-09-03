#!/system/bin/sh
# Astrofilm Gradle launcher for AndroidIDE.
# This launcher bootstraps Gradle 8.9 if AndroidIDE does not expose `gradle` on PATH.
set -e

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
GRADLE_VERSION="8.9"
BASE="${HOME:-/data/data/com.m4coding.ide/files/home}/.gradle/astrofilm-wrapper"
DIST="$BASE/gradle-$GRADLE_VERSION"
GRADLE_BIN="$DIST/bin/gradle"

if command -v gradle >/dev/null 2>&1; then
    exec gradle "$@"
fi

if [ -x "$GRADLE_BIN" ]; then
    exec "$GRADLE_BIN" "$@"
fi

mkdir -p "$BASE"
TMP="$BASE/gradle-$GRADLE_VERSION.zip"
URL="https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip"

echo "Gradle $GRADLE_VERSION is not installed. Downloading it..."
if command -v curl >/dev/null 2>&1; then
    curl -L --fail --retry 3 -o "$TMP" "$URL"
elif command -v wget >/dev/null 2>&1; then
    wget -O "$TMP" "$URL"
else
    echo "curl/wget is not available in AndroidIDE terminal." >&2
    exit 1
fi

rm -rf "$DIST"
if command -v unzip >/dev/null 2>&1; then
    unzip -q "$TMP" -d "$BASE"
else
    echo "unzip is not available in AndroidIDE terminal." >&2
    exit 1
fi

if [ ! -x "$GRADLE_BIN" ]; then
    echo "Gradle download/extraction failed." >&2
    exit 1
fi

# AndroidIDE requires its bundled aapt2 when building from the terminal.
if [ -x "${HOME}/.androidide/aapt2" ]; then
    exec "$GRADLE_BIN" -Pandroid.aapt2FromMavenOverride="${HOME}/.androidide/aapt2" "$@"
else
    exec "$GRADLE_BIN" "$@"
fi
