cask "easier-drop" do
  version "1.1.1"
  sha256 "e45cbfd3c0636b7c93cb4d271981ce544e517f24ff0ac58c5c4728883c9e859f"

  url "https://github.com/victorcmarinho/EasierDrop/releases/download/v#{version}/easier_drop-macos-universal-v#{version}.dmg"
  name "Easier Drop"
  desc "Drag and drop shelf"
  homepage "https://github.com/victorcmarinho/EasierDrop"

  app "Easier Drop.app"

  zap trash: [
    "~/Library/Application Support/easier_drop",
    "~/Library/Preferences/com.victorcmarinho.easierDrop.plist",
    "~/Library/Saved Application State/com.victorcmarinho.easierDrop.savedState",
  ]
end
