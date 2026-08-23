cask "easylaunchpad" do
  version "2.2.0"
  sha256 "45ed8c881bdbbfc9e4bb577e0cd1d86cf6a69192de0926e561d71ea44e9441ba"

  url "https://github.com/NonchalantLudens/EasyLaunchPad/releases/download/v#{version}/EasyLaunchPad-#{version}.dmg"
  name "EasyLaunchPad"
  desc "Full-screen app launcher recreating the classic Launchpad experience"
  homepage "https://github.com/NonchalantLudens/EasyLaunchPad"

  app "EasyLaunchPad.app"

  quarantine false
end
