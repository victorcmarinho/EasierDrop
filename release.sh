#!/bin/bash

# release.sh - Script for easier_drop build/release
# Usage: ./release.sh [--deploy]

set -e  # Stop on error

# Output Colors and styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper for nice headers
print_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"
}

# Configuration
APP_NAME="Easier Drop"
APP_BUNDLE_NAME="Easier Drop.app"        # Final Production App Name
DEBUG_APP_NAME="Easier Drop (Debug).app" # Final Debug App Name
BUILD_OUTPUT_DIR="$(pwd)/build/app"
PROJECT_ROOT="$(pwd)"

echo -e "${GREEN}🚀 Starting release process for ${BOLD}${APP_NAME}${NC}"
echo -e "${YELLOW}📍 Project Root: $PROJECT_ROOT${NC}"

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
print_header "1. Configuration"
echo -e "📖 Reading version from pubspec.yaml..."
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | sed 's/+.*//' | sed 's/^/v/')
if [[ -z "$VERSION" ]]; then
  echo -e "${RED}❌ Error: version not found in pubspec.yaml${NC}"
  exit 1
fi

echo -e "✅ Detected version: ${BOLD}${GREEN}${VERSION}${NC}"

# 2. CLEAN & SETUP
print_header "2. Environment Setup"
echo -e "🧹 Cleaning project..."
flutter clean > /dev/null
echo -e "📦 Getting dependencies..."
flutter pub get > /dev/null

# Prepare output directory (FLAT STRUCTURE)
rm -rf "$BUILD_OUTPUT_DIR"
mkdir -p "$BUILD_OUTPUT_DIR"

# 2.1 LOAD ENV VARS
echo -e "🔑 Loading environment variables..."
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
  echo -e "✅ Environment variables loaded."
else
  echo -e "${YELLOW}⚠️  .env file not found. Building without secrets.${NC}"
fi

# 3. BUILD DEBUG
print_header "3. Building DEBUG Version"
echo -e "⚙️ Compiling..."

flutter build macos --debug $DART_DEFINES > /dev/null

DEBUG_SRC="build/macos/Build/Products/Debug/easier_drop.app"
if [[ -d "$DEBUG_SRC" ]]; then
  cp -R "$DEBUG_SRC" "$BUILD_OUTPUT_DIR/$DEBUG_APP_NAME"
  echo -e "${GREEN}✅ Debug app built.${NC}"
else
  echo -e "${RED}❌ Error: Debug build failed (app not found).${NC}"
  exit 1
fi

# 4. BUILD RELEASE (Obfuscated & Split Debug Info)
print_header "4. Building RELEASE Version (Universal Build)"
echo -e "📦 Compiling with obfuscation and split debug info..."
echo -e "   This may take a minute..."
# Obfuscation and split-debug-info help reduce size
flutter build macos --release --obfuscate --split-debug-info=./build/debug-info $DART_DEFINES

RELEASE_SRC="build/macos/Build/Products/Release/easier_drop.app"

if [[ ! -d "$RELEASE_SRC" ]]; then
   echo -e "${RED}❌ Error: Release build failed (app not found).${NC}"
   exit 1
fi

# Helper function to package for an arch
package_arch() {
    local ARCH=$1
    local SUFFIX=$2 # e.g., "arm64" or "x64" or "universal"
    
    echo -e "\n${BOLD}🔨 Processing ${ARCH} (${SUFFIX})...${NC}"

    local APP_DEST="${BUILD_OUTPUT_DIR}/${SUFFIX}/Easier Drop.app"
    local ZIP_NAME="easier_drop-macos-${SUFFIX}-${VERSION}.zip"
    local DMG_NAME="easier_drop-macos-${SUFFIX}-${VERSION}.dmg"
    local DMG_PATH="$BUILD_OUTPUT_DIR/$DMG_NAME"
    
    mkdir -p "${BUILD_OUTPUT_DIR}/${SUFFIX}"
    cp -R "$RELEASE_SRC" "$APP_DEST"

    # If specific arch requested (not universal), thin the binary
    if [[ "$ARCH" != "universal" ]]; then
        local BINARY="$APP_DEST/Contents/MacOS/easier_drop"
        echo "   🔪 Thinning binary to $ARCH..."
        lipo -thin "$ARCH" "$BINARY" -output "$BINARY" || {
             echo -e "${YELLOW}⚠️  Failed to thin binary for $ARCH. It might already be single-arch.${NC}"
        }
    fi
    
    # Create ZIP
    echo "   🤐 Creating ZIP..."
    (cd "${BUILD_OUTPUT_DIR}/${SUFFIX}" && zip -r -y "$BUILD_OUTPUT_DIR/$ZIP_NAME" "Easier Drop.app" -x "*.DS_Store") > /dev/null
    
    # Create DMG
    echo "   💿 Creating DMG..."
    local DMG_STAGING="${BUILD_OUTPUT_DIR}/${SUFFIX}/dmg_temp"
    rm -rf "$DMG_STAGING"
    mkdir -p "$DMG_STAGING"
    cp -R "$APP_DEST" "$DMG_STAGING/"
    ln -s /Applications "$DMG_STAGING/Applications"
    
    hdiutil create -volname "$APP_NAME" \
      -srcfolder "$DMG_STAGING" \
      -ov -format UDZO "$DMG_PATH" \
      -quiet
      
    rm -rf "$DMG_STAGING"
    
    local SIZE=$(du -sh "$DMG_PATH" | awk '{print $1}')
    echo -e "${GREEN}✅ Artifacts ready for ${SUFFIX}. DMG Size: ${SIZE}${NC}"
}

# 5. SPLIT AND PACKAGE
print_header "5. Packaging & Splitting"
# Verify if it's a universal binary
BINARY_PATH="$RELEASE_SRC/Contents/MacOS/easier_drop"
ARCHS=$(lipo -info "$BINARY_PATH")

echo -e "ℹ️  Source Architectures: ${ARCHS}"

# Always package Universal
echo -e "${YELLOW}✨ Packaging Universal Binary...${NC}"
package_arch "universal" "universal"

if [[ "$ARCHS" == *"x86_64"* && "$ARCHS" == *"arm64"* ]]; then
    echo -e "${YELLOW}✨ Universal binary detected. Creating split packages...${NC}"
    package_arch "arm64" "arm64"
    package_arch "x86_64" "x64"
else
    echo -e "${YELLOW}⚠️  Not a universal binary. Skipping splitting.${NC}"
fi


# 6. DEPLOY (Optional)
if [[ "$DEPLOY" == true ]]; then
  print_header "6. Deployment (GitHub Releases)"
  
  if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not found. Install with: brew install gh${NC}"
    exit 1
  fi
  
  # Check if we are in a git repo
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
      echo -e "${RED}❌ Not a git repository.${NC}"
      exit 1
  fi

  echo -e "📤 Committing changes..."
  git add .
  git commit -m "Release ${VERSION}" || echo "   Nothing to commit"
  git push origin main
  
  echo -e "🏷️  Checking Tags..."
  if git rev-parse "$VERSION" >/dev/null 2>&1; then
      echo "   ⚠️ Tag $VERSION already exists. Skipping tag creation."
  else
      echo "   ✨ Creating tag ${VERSION}..."
      git tag "$VERSION"
      git push origin "$VERSION"
  fi

  # Extract Changelog for this version
  RAW_VERSION=${VERSION#v}
  echo -e "📄 Extracting changelog notes for version ${BOLD}${RAW_VERSION}${NC}..."
  CHANGELOG_NOTES=$(awk "/^## \[${RAW_VERSION}\]/{flag=1; next} /^## \[/{flag=0} flag" CHANGELOG.md)

  if [[ -z "$CHANGELOG_NOTES" ]]; then
    echo -e "${YELLOW}⚠️  No specific notes found in CHANGELOG.md for this version. Using default.${NC}"
    CHANGELOG_NOTES="Official macOS release."
  else
    echo -e "   ✅ Clean changelog extracted."
  fi

  echo -e "🚀 Creating GitHub Release..."
  
  # Collect all assets
  ASSETS=()
  for f in "$BUILD_OUTPUT_DIR"/*.zip "$BUILD_OUTPUT_DIR"/*.dmg; do
      if [[ -f "$f" ]]; then
          ASSETS+=("$f")
      fi
  done
  
  gh release create "$VERSION" "${ASSETS[@]}" \
    --title "${APP_NAME} ${VERSION}" \
    --generate-notes \
    --notes "
🚀 **${APP_NAME} ${VERSION}**

${CHANGELOG_NOTES}

## 📦 Downloads

| Architecture | DMG Installer | ZIP Portable |
|:---:|:---:|:---:|
| **Universal (Standard)** | [Download](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-universal-${VERSION}.dmg) | [ZIP](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-universal-${VERSION}.zip) |
| **Apple Silicon (M1/M2/M3)** | [Download (arm64)](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-arm64-${VERSION}.dmg) | [ZIP](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-arm64-${VERSION}.zip) |
| **Intel** | [Download (x64)](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-x64-${VERSION}.dmg) | [ZIP](https://github.com/victorcmarinho/EasierDrop/releases/download/${VERSION}/easier_drop-macos-x64-${VERSION}.zip) |

---
*Built with Flutter*
"

  echo -e "${GREEN}🎉 Release published successfully!${NC}"
  echo -e "   🔗 URL: https://github.com/victorcmarinho/EasierDrop/releases/tag/${VERSION}"
else
  print_header "6. Deployment Skipped"
  echo -e "${YELLOW}ℹ️  To publish to GitHub, use: ./release.sh --deploy${NC}"
fi

print_header "🏁 Build Summary"
echo -e "${GREEN}✨ Process finished successfully!${NC}"

echo -e "\n${BOLD}Generated Artifacts:${NC}"
printf "%-15s %-40s\n" "SIZE" "FILENAME"
echo "--------------------------------------------------------"

# Function to get human readable size with decimals
get_file_size() {
    local path="$1"
    if [[ -d "$path" ]]; then
        # Directory: use du -sk (KB)
        local kb=$(du -sk "$path" | awk '{print $1}')
        echo "$kb" | awk '{ printf "%.2f MB", $1/1024 }'
    elif [[ -f "$path" ]]; then
        # File: use wc -c (Bytes)
        local bytes=$(wc -c < "$path")
        echo "$bytes" | awk '{ printf "%.2f MB", $1/1024/1024 }'
    else
        echo "N/A"
    fi
}

# 1. Debug App
DEBUG_APP="$BUILD_OUTPUT_DIR/$DEBUG_APP_NAME"
if [[ -d "$DEBUG_APP" ]]; then
    size=$(get_file_size "$DEBUG_APP")
    filename="$DEBUG_APP_NAME"
    printf "%-15s %-40s\n" "$size" "$filename"
fi

# 2. Release Artifacts
find "$BUILD_OUTPUT_DIR" -name "*.dmg" -o -name "*.zip" | sort | while read -r file; do
    size=$(get_file_size "$file")
    filename=$(basename "$file")
    printf "%-15s %-40s\n" "$size" "$filename"
done
echo "--------------------------------------------------------"

