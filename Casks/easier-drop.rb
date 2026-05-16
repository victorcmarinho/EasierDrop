cask "easier-drop" do
  version "1.2.0"
  sha256 "5dbbf54997008a54eb9dc0316b24a35d44b93fc44e5bcc96ed6303e1987ba01c"

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
