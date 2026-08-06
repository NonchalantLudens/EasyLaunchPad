cask "easylaunchpad" do
  version "0.1.0"
  sha256 "42164a6ab5d12a47f9eb12b1a40f8a67e75e9648c023309b0a000178b1bad145"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
