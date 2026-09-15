cask "easylaunchpad" do
  version "2.5.1"
  sha256 "704c1e3cfdc3f4bea7397898872e37b4d5a2129fb945279ba6ef92ddf0d87606"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
