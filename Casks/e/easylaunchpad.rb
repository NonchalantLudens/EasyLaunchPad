cask "easylaunchpad" do
  version "0.1.0"
  sha256 "8b805e0c4d153c80c377b6c4badc578f856b9bf667328d9878828b017769f78c"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"
end
