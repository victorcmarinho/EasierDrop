cask "easier-drop" do
  version "1.2.1"
  sha256 "3861dd144d82e4be5e28b2fa67bd42e2ef8f9ddcd8de98980e53e5b90eb02c2a"

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
