class Hiredis < Formula
  desc "Minimalistic client for Redis"
  homepage "https://github.com/redis/hiredis"
  url "https://github.com/redis/hiredis/archive/v0.14.1.tar.gz"
  sha256 "2663b2aed9fd430507e30fc5e63274ee40cdd1a296026e22eafd7d99b01c8913"
  license "BSD-3-Clause"
  revision 1
  head "https://github.com/redis/hiredis.git"

  bottle do
    cellar :any
    sha256 "e56680ffe95af8db4989e9a0d9bb0fe546cd61b337049d570cfb073cff8a066c" => :big_sur
    sha256 "18e913416a9138855a932395036bc9bc27a178e359b8aaf48a82d56d45d90b70" => :arm64_big_sur
    sha256 "4b089bee868b4fe533bea75917f21a42a11a9e04d5b396ec5a94d5623372ec0b" => :catalina
    sha256 "8974f8bacac7ce018f6f238915c6c5f07751c5183283337634a1715624d344b8" => :mojave
    sha256 "5ed94f51e6dbe91f7d195be5a5d085c7929f82bafeecba8645dd2315a94dad8d" => :high_sierra
  end

  def install
    system "make", "install", "PREFIX=#{prefix}"
    pkgshare.install "examples"
  end

  test do
    # running `./test` requires a database to connect to, so just make
    # sure it compiles
    system ENV.cc, "-I#{include}/hiredis", "-L#{lib}", "-lhiredis",
           pkgshare/"examples/example.c", "-o", testpath/"test"
    assert_predicate testpath/"test", :exist?
  end
end
