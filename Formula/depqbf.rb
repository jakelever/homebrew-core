class Depqbf < Formula
  desc "Solver for quantified boolean formulae (QBF)"
  homepage "https://lonsing.github.io/depqbf/"
  url "https://github.com/lonsing/depqbf/archive/version-5.0.tar.gz"
  sha256 "9a4c9a60246e1c00128ae687f201b6dd309ece1e7601a6aa042a6317206f5dc7"
  head "https://github.com/lonsing/depqbf.git"

  bottle do
    cellar :any
    sha256 "7c0b8ef336f9d2bac14e11f0ca838620428376ba4b1f29b6ac3614d3a5f61774" => :el_capitan
    sha256 "d10617714d882cce0a4a8754c03fe7f9df7adf01de8b0016cceafe092e98c163" => :yosemite
    sha256 "92ef32e3fff775db370d3c83ee1b09c0d3c7debab448be37f30465094b17f028" => :mavericks
    sha256 "cc339acae9c477f4ebead71e79b2f59d9f9a3bf4ac2afada0092ed440899448a" => :x86_64_linux
  end

  def install
    # Fixes "ld: unknown option: -soname"
    # Reported 5 Sep 2016 https://github.com/lonsing/depqbf/issues/8
    inreplace "makefile" do |s|
      s.gsub! "-Wl,-soname,libqdpll.so.$(MAJOR)", ""
      s.gsub! ".so.$(VERSION)", ".$(VERSION).dylib"
    end if OS.mac?

    system "make"
    bin.install "depqbf"
    lib.install "libqdpll.a"
    lib.install "libqdpll.#{OS.mac? ? "1.0.dylib" : "so.1.0"}"
  end

  test do
    system "#{bin}/depqbf", "-h"
  end
end
