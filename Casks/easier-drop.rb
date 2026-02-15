cask "easier-drop" do
  version "1.1.2"
  sha256 "876bbe53a1e6e3311ccdbf76d7fa214aea51677b915041700ec64de54db391dd"

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
