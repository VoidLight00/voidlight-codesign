cask "voidlight-codesign" do
  version "0.1.4-ko-alpha"
  arch arm: "arm64", intel: "x64"

  sha256 arm:   "b727793406e4b737a8d748dc69bd7591acfa555b713db480b2f067f399df31a3",
         intel: "73c84b107422b1ddcdc536988c2bb94123438fdd4aa6101df23c453d75df8295"

  url "https://github.com/VoidLight00/voidlight-codesign/releases/download/v#{version}/voidlight-codesign-0.1.4-#{arch}.dmg"
  name "VoidLight CoDesign"
  desc "Korean developer preview fork of Open CoDesign"
  homepage "https://github.com/VoidLight00/voidlight-codesign"

  # alpha-ko 채널은 pre-release 태그를 사용한다.
  # :github_latest는 pre-release를 건너뛰므로 :github_releases를 사용한다.
  # stable-ko 채널 승격 시 :github_latest로 전환할 것.
  livecheck do
    url :url
    strategy :github_releases
  end

  depends_on macos: ">= :ventura"

  app "VoidLight CoDesign.app"

  caveats <<~EOS
    VoidLight CoDesign #{version} is an alpha/developer preview.

    - This build may be unsigned and not notarized.
    - Prefer the official API key provider path when possible.
    - VibeProxy/CLIProxyAPI is experimental and may carry provider ToS or account-policy risk.
    - This project is based on Open CoDesign by OpenCoworkAI and preserves MIT license attribution.

    If macOS blocks an unsigned alpha build, review the Korean installation guide before changing Gatekeeper or quarantine settings.
  EOS

  zap trash: [
    "~/Library/Application Support/VoidLight CoDesign",
    "~/Library/Preferences/ai.voidlight.codesign.plist",
    "~/Library/Saved Application State/ai.voidlight.codesign.savedState"
  ]
end
