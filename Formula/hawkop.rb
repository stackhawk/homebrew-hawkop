class Hawkop < Formula
  desc "CLI companion for the StackHawk AppSec Intelligence Platform"
  homepage "https://www.stackhawk.com/"
  license "MIT"

  on_macos do
    on_intel do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v0.6.1-x86_64-apple-darwin.tar.gz"
      sha256 "21056d87b8a57a219988e8987b8f994cb7c559e19d8909296edb2f369f93ab60"
    end
    on_arm do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v0.6.1-aarch64-apple-darwin.tar.gz"
      sha256 "eab83057153f71ae1262a916f1a82bf75bd1fdede7113aba21673b2531834ace"
    end
  end

  on_linux do
    on_intel do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v0.6.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "29afb9f6be871894520998c7676cacae7cc7a6ea260dcae5aa3b1842cbb07c8d"
    end
    on_arm do
      url "https://download.stackhawk.com/hawkop/cli/hawkop-v0.6.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "740ba86a48adcb09ded2fddf10ea14c5f4e6510af50bb37bb59f502ca8037a6e"
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
