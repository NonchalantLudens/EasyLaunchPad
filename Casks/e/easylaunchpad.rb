cask "easylaunchpad" do
  version "2.4.0"
  sha256 "e4ff59669607911ae19670e23fb70e62ed446b4b1623588a9bdd130a22a2aa8f"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
