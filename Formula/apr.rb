class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-1.5.2.tar.bz2"
  sha256 "7d03ed29c22a7152be45b8e50431063736df9e1daa1ddf93f6a547ba7a28f67a"
  revision OS.mac? ? 2 : 4

  bottle do
    cellar :any
    sha256 "8a9f56c07ce43d3d4ab964da863625187e06be4fea8e99a488cbf0ec9832f532" => :el_capitan
    sha256 "08595cd95ac27346c4411ddabae93a388950237f02a37f3b8d371361d51d507f" => :yosemite
    sha256 "627e691c080851b854abc3affcf7d53c32c33fb7bb3bc00646f877b670f7b498" => :mavericks
    sha256 "f9b28bd6ec00adfe12f12aa7f9e81281c5b286fd3d3eba3ca1d9909920673433" => :x86_64_linux
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr."

  option :universal

  depends_on "util-linux" => :recommended if OS.linux? # for libuuid

  def install
    ENV.universal_binary if build.universal?

    # https://bz.apache.org/bugzilla/show_bug.cgi?id=57359
    # The internal libtool throws an enormous strop if we don't do...
    ENV.deparallelize

    if OS.linux? && build.bottle?
      # Prevent hardcoded /usr/bin/gcc-4.8 compiler
      ENV["CC"] = "cc"
    end

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    lib.install_symlink Dir["#{libexec}/lib/*.so*"] unless OS.mac?

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apr-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apr-1-config --prefix")
  end
end
