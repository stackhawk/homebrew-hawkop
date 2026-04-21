# This file is rendered by scripts/update-formula.sh to produce Formula/hawkop.rb.
# Do not edit Formula/hawkop.rb by hand.
class Hawkop < Formula
  desc "CLI companion for the StackHawk AppSec Intelligence Platform"
  homepage "https://www.stackhawk.com/"
  version "${version}"
  license "MIT"

  on_macos do
    on_intel do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v${version}-x86_64-apple-darwin.tar.gz"
      sha256 "${mac_x64_sha256}"
    end
    on_arm do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v${version}-aarch64-apple-darwin.tar.gz"
      sha256 "${mac_arm64_sha256}"
    end
  end

  on_linux do
    on_intel do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v${version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "${linux_x64_sha256}"
    end
    on_arm do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v${version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "${linux_arm64_sha256}"
    end
  end

  def install
    bin.install "hawkop"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hawkop --version")
    system bin/"hawkop", "--help"
  end
end
