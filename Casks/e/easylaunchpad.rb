cask "easylaunchpad" do
  version "2.4.1"
  sha256 "e68e3a1674b239a0faa5bf0b3ea43fa412f45986b1f9d9ea09003d4749b81d43"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
