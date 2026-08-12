cask "easylaunchpad" do
  version "0.1.0"
  sha256 "adfb65c08d4113154f03806ef3f1ef294f579e21bf4028bd1a621bcf066545a8"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
