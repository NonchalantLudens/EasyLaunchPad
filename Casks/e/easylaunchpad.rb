cask "easylaunchpad" do
  version "2.5.2"
  sha256 "4a9970682061751e11b91875eab0b2dc904ce3cf23e8fe05e755adc79d5e7432"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
