cask "easylaunchpad" do
  version "0.1.0"
  sha256 "83c6212e3218813e8f5bf94639cc01039570d9f45332439af8cdbe65f0be796b"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
