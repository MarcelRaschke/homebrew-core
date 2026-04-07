class BalenaCli < Formula
  desc "Command-line tool for interacting with the balenaCloud and balena API"
  homepage "https://docs.balena.io/reference/balena-cli/latest/"
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-24.1.0.tgz"
  sha256 "b9d75e66fb3c8d4b95a98767000d65adf75cac49e3c7c7264ffc97e256d42a40"
  license "Apache-2.0"

  livecheck do
    url "https://registry.npmjs.org/balena-cli/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "f9c4868ef575e5b116afb03c805e40e84e7b1d5b86a15cde96a575948e01eefe"
    sha256 cellar: :any,                 arm64_sequoia: "7798a4c8eb691a75c7bf4f582400ded3ef3d402c2f607f42004d387f9f4079d3"
    sha256 cellar: :any,                 arm64_sonoma:  "7798a4c8eb691a75c7bf4f582400ded3ef3d402c2f607f42004d387f9f4079d3"
    sha256 cellar: :any,                 sonoma:        "644dbc9e7dc3b7f7a13970ede9ec5ca2a840b3e0500125372728122a35790097"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "1fc4aa67b501b41a7c68c092ec162fd59c4dcee1b632ebd3dae9d03d68b9d068"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5b0fc25dc16ac0c456501ab8c2412fe186b13d9901ff12634be7a7d74bfa75e1"
  end

  depends_on "node"

  on_linux do
    depends_on "libusb"
    depends_on "systemd" # for libudev
    depends_on "xz" # for liblzma
  end

  def install
    ENV.deparallelize

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    modules = %w[
      bare-fs
      bare-os
      bare-url
      bcrypt
      lzma-native
      mountutils
      xxhash-addon
    ]
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/balena-cli/node_modules"
    node_modules.glob("{#{modules.join(",")}}/prebuilds/*")
                .each do |dir|
                  if dir.basename.to_s == "#{os}-#{arch}"
                    dir.glob("*.musl.node").each(&:unlink) if OS.linux?
                  else
                    rm_r(dir)
                  end
                end

    rm_r(node_modules/"usb") if OS.linux?

    # Replace universal binaries with native slices
    deuniversalize_machos
  end

  test do
    assert_match "Logging in to balena-cloud.com",
      shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
  end
end
