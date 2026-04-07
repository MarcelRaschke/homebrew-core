class StripeCli < Formula
  desc "Command-line tool for Stripe"
  homepage "https://docs.stripe.com/stripe-cli"
  url "https://github.com/stripe/stripe-cli/archive/refs/tags/v1.40.1.tar.gz"
  sha256 "beb22d7609278a9faa9caba4e5d660342c6cb414ffccfbe0b798f1db1cc6b39b"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "be58ad7cd7d21eb32b14e6fc15d4eb6a2136ef63b3aa81ec7e8f78d1129c6340"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "11d43d448ed8e171324c90c40d845d2190078032541936c43550a041f55cfba7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f1a36dc20a640142c743b20e1d695de02c3303cdf67e0ea61d67eeabaf989309"
    sha256 cellar: :any_skip_relocation, sonoma:        "a5d81c3db3dddb9aa2c00dfb3e015c1dd9cd81e560cc75314097f45d53989412"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9254c11eba3df6102c81f8d9d181103caa59a6f4728d1202b0f2cf18fbf4329c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7b1f37f7aa6ddbfbeab1a04ef284cdde2298122444887702441bb8334efa2650"
  end

  depends_on "go" => :build

  def install
    # See configuration in `.goreleaser` directory
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    ldflags = %W[-s -w -X github.com/stripe/stripe-cli/pkg/version.Version=#{version}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"stripe"), "cmd/stripe/main.go"

    # TODO: see if fish support is added, ref: https://github.com/stripe/stripe-cli/pull/1282
    generate_completions_from_executable(bin/"stripe", "completion", "--write-to-stdout", "--shell",
                                         shells: [:bash, :zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/stripe version")
    assert_match "secret or restricted key",
                 shell_output("#{bin}/stripe --api-key=not_real_key get ch_1EGYgUByst5pquEtjb0EkYha", 1)
    assert_match "-F __start_stripe",
                 shell_output("bash -c 'source #{bash_completion}/stripe && complete -p stripe'")
  end
end
