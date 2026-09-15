cask "easylaunchpad" do
  version "2.5.0"
  sha256 "7005948029e6d1d3d95244b3b359568ad3be39a07f6e480799a5aaa00d839112"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
