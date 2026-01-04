#!/bin/bash

# release.sh - Script for easier_drop build/release
# Usage: ./release.sh [--deploy]

set -e  # Stop on error

# Output Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Easier Drop"
APP_BUNDLE_NAME="Easier Drop.app"        # Final Production App Name
DEBUG_APP_NAME="Easier Drop (Debug).app" # Final Debug App Name
BUILD_OUTPUT_DIR="$(pwd)/build/app"
PROJECT_ROOT="$(pwd)"

echo -e "${GREEN}🚀 Starting release process for ${APP_NAME}${NC}"
echo -e "${YELLOW}📍 Project: $PROJECT_ROOT${NC}"

# Parse arguments
DEPLOY=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --deploy)
      DEPLOY=true
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# 1. READ VERSION FROM pubspec.yaml
echo -e "${BLUE}📖 1. Reading version from pubspec.yaml...${NC}"
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | sed 's/+.*//' | sed 's/^/v/')
if [[ -z "$VERSION" ]]; then
  echo -e "${RED}❌ Error: version not found in pubspec.yaml${NC}"
  exit 1
fi

DMG_NAME="easier_drop-macos-${VERSION}.dmg"
ZIP_NAME="easier_drop-macos-${VERSION}.zip"
echo -e "${GREEN}✅ Detected version: ${VERSION}${NC}"

# 2. CLEAN & SETUP
echo -e "${BLUE}🧹 2. Cleaning project...${NC}"
flutter clean
flutter pub get

# Prepare output directory (FLAT STRUCTURE)
rm -rf "$BUILD_OUTPUT_DIR"
mkdir -p "$BUILD_OUTPUT_DIR"

# 2.1 LOAD ENV VARS
echo -e "${BLUE}🔑 2.1 Loading environment variables...${NC}"
DART_DEFINES=""
if [ -f .env ]; then
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    if [[ ! $key =~ ^# && -n $key ]]; then
      # Trim whitespace
      key=$(echo "$key" | xargs)
      value=$(echo "$value" | xargs)
      DART_DEFINES="$DART_DEFINES --dart-define=$key=$value"
    fi
  done < .env
  echo -e "${GREEN}✅ Environment variables loaded.${NC}"
else
  echo -e "${YELLOW}⚠️  .env file not found. Building without secrets.${NC}"
fi

# 3. BUILD DEBUG
echo -e "${BLUE}🐞 3. Building DEBUG version...${NC} "

flutter build macos --debug $DART_DEFINES

DEBUG_SRC="build/macos/Build/Products/Debug/easier_drop.app"
if [[ -d "$DEBUG_SRC" ]]; then
  cp -R "$DEBUG_SRC" "$BUILD_OUTPUT_DIR/$DEBUG_APP_NAME"
  echo -e "${GREEN}✅ Debug app built: $BUILD_OUTPUT_DIR/$DEBUG_APP_NAME${NC}"
else
  echo -e "${RED}❌ Error: Debug build failed (app not found).${NC}"
  exit 1
fi

# 4. BUILD RELEASE
echo -e "${BLUE}📦 4. Building RELEASE version...${NC}"
flutter build macos --release $DART_DEFINES

RELEASE_SRC="build/macos/Build/Products/Release/easier_drop.app"
RELEASE_DEST="$BUILD_OUTPUT_DIR/$APP_BUNDLE_NAME"

if [[ -d "$RELEASE_SRC" ]]; then
  cp -R "$RELEASE_SRC" "$RELEASE_DEST"
  echo -e "${GREEN}✅ Release app built: $RELEASE_DEST${NC}"
else
  echo -e "${RED}❌ Error: Release build failed (app not found).${NC}"
  exit 1
fi

# 5. CREATE ZIP (From Release App)
echo -e "${BLUE}🤐 5. Creating ZIP archive...${NC}"
# Use ditto for best macOS compatibility (preserves resources/permissions)
# ditto -c -k --sequesterRsrc --keepParent "$RELEASE_DEST" "$BUILD_OUTPUT_DIR/$ZIP_NAME"
# Or just zip for simplicity:
(cd "$BUILD_OUTPUT_DIR" && zip -r -y "$ZIP_NAME" "$APP_BUNDLE_NAME" -x "*.DS_Store")

echo -e "${GREEN}✅ ZIP Created: $BUILD_OUTPUT_DIR/$ZIP_NAME${NC}"

# 6. CREATE DMG (With /Applications Link)
echo -e "${BLUE}💿 6. Creating DMG...${NC}"
DMG_PATH="$BUILD_OUTPUT_DIR/$DMG_NAME"
DMG_STAGING="$BUILD_OUTPUT_DIR/dmg_temp"

# Prepare staging area
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

# Copy App to staging
cp -R "$RELEASE_DEST" "$DMG_STAGING/"

# Create /Applications symlink
ln -s /Applications "$DMG_STAGING/Applications"

echo "   Generating DMG image..."
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov -format UDZO "$DMG_PATH" \
  -quiet

# Cleanup staging
rm -rf "$DMG_STAGING"

echo -e "${GREEN}✅ DMG Created: $DMG_PATH${NC}"
echo -e "   📊 Size: $(du -sh "$DMG_PATH" | awk '{print $1}')"

# 7. DEPLOY (Optional)
if [[ "$DEPLOY" == true ]]; then
  echo -e "${BLUE}📤 7. Deploying to GitHub...${NC}"
  
  if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not found. Install with: brew install gh${NC}"
    exit 1
  fi
  
  # Check if we are in a git repo
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      echo -e "${RED}❌ Not a git repository.${NC}"
      exit 1
  fi

  echo "   Committing changes..."
  git add .
  git commit -m "Release ${VERSION}" || echo "Nothing to commit"
  git push origin main
  
  if git rev-parse "$VERSION" >/dev/null 2>&1; then
      echo "   ⚠️ Tag $VERSION already exists. Skipping tag creation."
  else
      git tag "$VERSION"
      git push origin "$VERSION"
  fi

  # Extract Changelog for this version
  RAW_VERSION=${VERSION#v}
  echo "   📄 Extracting changelog for version $RAW_VERSION..."
  CHANGELOG_NOTES=$(awk "/^## \[${RAW_VERSION}\]/{flag=1; next} /^## \[/{flag=0} flag" CHANGELOG.md)

  if [[ -z "$CHANGELOG_NOTES" ]]; then
    CHANGELOG_NOTES="Official macOS release."
  fi

  echo "   Creating GitHub Release..."
  gh release create "$VERSION" "$DMG_PATH" "$BUILD_OUTPUT_DIR/$ZIP_NAME" \
    --title "${APP_NAME} ${VERSION}" \
    --generate-notes \
    --notes "
🚀 **${APP_NAME} ${VERSION}**

${CHANGELOG_NOTES}

## 📦 Downloads
- **DMG Installer**: Drag and drop installation.
- **ZIP**: Portable application.

### Installation
1. Download **${DMG_NAME}**
2. Open it and drag **${APP_NAME}** to the **Applications** folder 📂
3. Enjoy!

---
*Built with Flutter*
"

  echo -e "${GREEN}🎉 Release published: https://github.com/victorcmarinho/EasierDrop/releases/tag/${VERSION}${NC}"
else
  echo -e "${YELLOW}ℹ️  To publish to GitHub, use: ./release.sh --deploy${NC}"
fi

echo -e "${GREEN}✨ Process finished!${NC}"
echo -e "${YELLOW}📂 Output Directory: $BUILD_OUTPUT_DIR${NC}"
echo -e "   🐞 Debug App:  $DEBUG_APP_NAME"
echo -e "   � Release App: $APP_BUNDLE_NAME"
echo -e "   🤐 ZIP File:    $ZIP_NAME"
echo -e "   💿 DMG File:    $DMG_NAME"
