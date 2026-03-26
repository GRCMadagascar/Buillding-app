#!/usr/bin/env bash
# get-sha1.sh - print Android SHA-1 fingerprints (run from project root)
# Usage: ./scripts/get-sha1.sh
set -euo pipefail
echo "=== GRC POS - SHA-1 helper ==="

# Check JAVA_HOME
if [ -n "${JAVA_HOME:-}" ]; then
  echo "JAVA_HOME=$JAVA_HOME"
else
  echo "WARNING: JAVA_HOME is not set. keytool may not be available on PATH."
fi

cd "$(dirname "$0")/../android" || { echo "Cannot cd to android/"; exit 1; }

# If gradlew exists, run signingReport
if [ -f "./gradlew" ]; then
  echo "Running ./gradlew signingReport..."
  ./gradlew signingReport
  exit 0
fi

if [ -f "./gradlew.bat" ]; then
  echo "Found gradlew.bat (Windows wrapper) - please run the batch script on Windows."
  exit 1
fi

echo "No Gradle wrapper found. Falling back to keytool against debug keystore."
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
  echo "Using debug keystore: $DEBUG_KEYSTORE"
  if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/keytool" ]; then
    "$JAVA_HOME/bin/keytool" -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android
  else
    echo "Attempting to use keytool from PATH..."
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android
  fi
  exit 0
else
  echo "Debug keystore not found at $DEBUG_KEYSTORE"
  echo "Run the app once with 'flutter run' to generate the debug keystore or provide your release keystore path."
  exit 1
fi
