#!/bin/bash

# Configuration
PROJECT_NAME="RedoLife.xcodeproj"
SCHEME_NAME="Fix My Life"
APP_NAME="Fix My Life"  # The name of the resulting .app file (usually matches Target/Scheme)
DMG_NAME="FixMyLife_Installer.dmg"
BUILD_DIR="./build"

echo "🚀 Starting Build Process for $APP_NAME..."

# 1. Clean and Build
xcodebuild -project "$PROJECT_NAME" \
           -scheme "$SCHEME_NAME" \
           -configuration Release \
           clean build \
           CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED="NO" \
           CODE_SIGNING_ALLOWED="NO"

# Check if build succeeded
if [ $? -ne 0 ]; then
    echo "❌ Build Failed"
    exit 1
fi

echo "✅ Build Successful!"

# 2. Prepare DMG Structure
echo "📦 Preparing DMG..."
DMG_TMP_DIR="./dmg_tmp"
mkdir -p "$DMG_TMP_DIR"
rm -rf "$DMG_TMP_DIR/*"

# Copy App to tmp dir
cp -R "$BUILD_DIR/$APP_NAME.app" "$DMG_TMP_DIR/"

# Create Link to Applications
ln -s /Applications "$DMG_TMP_DIR/Applications"

# 3. Create DMG
echo "💿 Creating DMG file..."
rm -f "$DMG_NAME"
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_TMP_DIR" -ov -format UDZO "$DMG_NAME"

# Cleanup
rm -rf "$DMG_TMP_DIR"
# rm -rf "$BUILD_DIR" # Optional: keep build dir or delete

echo "🎉 Done! Your DMG is ready: $DMG_NAME"
echo "👉 You can send this file to other Macs (Note: Tell them to use 'xattr -cr' if it says damaged)"
