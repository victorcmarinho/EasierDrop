cask "easier-drop" do
  version "1.1.1"
  sha256 :no_check

  url "https://github.com/victorcmarinho/EasierDrop/releases/download/v#{version}/easier_drop-macos-universal-v#{version}.dmg"
  name "Easier Drop"
  desc "Drag and drop shelf for macOS"
  homepage "https://github.com/victorcmarinho/EasierDrop"

  app "Easier Drop.app"

  zap trash: [
    "~/Library/Application Support/easier_drop",
    "~/Library/Preferences/com.victorcmarinho.easierDrop.plist",
    "~/Library/Saved Application State/com.victorcmarinho.easierDrop.savedState",
  ]
end
