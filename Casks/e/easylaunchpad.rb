cask "easylaunchpad" do
  version "2.0.0"
  sha256 "b7485e23738ac325f2fbe328e6d4ac22067d2793b7996c7c76d11dbddc4776c9"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
