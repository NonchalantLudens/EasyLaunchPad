cask "easylaunchpad" do
  version "2.5.3"
  sha256 "c65cdd53a97b1d582261d9f48c2f3565e73f130d966fd42db7e1bcebb797fafa"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
