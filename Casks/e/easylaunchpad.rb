cask "easylaunchpad" do
  version "2.4.2"
  sha256 "2aa48bde0db149c704417ee0d4654a13fc4dbd9fa799d8f132d11c22d7e1341f"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
