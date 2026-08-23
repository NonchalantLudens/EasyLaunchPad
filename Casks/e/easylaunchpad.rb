cask "easylaunchpad" do
  version "2.3.0"
  sha256 "6c833d2f6dce1c614af8ad7a630336b17a6d9dd47785cd256f73bd161b981fc7"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
