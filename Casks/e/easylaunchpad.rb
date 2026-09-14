cask "easylaunchpad" do
  version "2.4.1"
  sha256 "24a460a4a32669354370b02702ea9df8e2c70f21f0002b3778dbb216efd0ca49"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
