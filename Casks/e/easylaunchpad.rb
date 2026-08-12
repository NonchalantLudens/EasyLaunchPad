cask "easylaunchpad" do
  version "0.1.0"
  sha256 "dadda00f8f5e93e9f040c62c88c26e8515bd2b2fc3413f47fdf4f18fbd99e84b"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
