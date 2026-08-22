cask "easylaunchpad" do
  version "2.1.0"
  sha256 "080f9b9a2d13ee48082a2e6bf08ee3b41b72fa6d2a3b55eb35ed563e5f9539c1"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
