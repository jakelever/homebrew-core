class Ncmpcpp < Formula
  desc "Ncurses-based client for the Music Player Daemon"
  homepage "https://rybczak.net/ncmpcpp/"
  url "https://ncmpcpp.rybczak.net/stable/ncmpcpp-0.7.4.tar.bz2"
  sha256 "d70425f1dfab074a12a206ddd8f37f663bce2bbdc0a20f7ecf290ebe051f1e63"
  revision 1

  bottle do
    cellar :any
    sha256 "45e9c648704f1445c733b39c4390a48b79e1b5147946a4bf254018fd57ca705c" => :el_capitan
    sha256 "a401ace7ad6819a3647dce24004775668399750940326ac6b179a8efc6583380" => :yosemite
    sha256 "5d005689e6226e585aee796610939b04251a1a5fe45cd32049b056c614000789" => :mavericks
    sha256 "41a1d023cabe43efaa5861e7538c27cdcb2ab75087689db7a13a6a196d24dc61" => :x86_64_linux
  end

  head do
    url "git://repo.or.cz/ncmpcpp.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  deprecated_option "outputs" => "with-outputs"
  deprecated_option "visualizer" => "with-visualizer"
  deprecated_option "clock" => "with-clock"

  option "with-outputs", "Compile with mpd outputs control"
  option "with-visualizer", "Compile with built-in visualizer"
  option "with-clock", "Compile with optional clock tab"

  depends_on "pkg-config" => :build
  depends_on "libmpdclient"
  depends_on "readline"
  depends_on "fftw" if build.with? "visualizer"

  if OS.mac? && MacOS.version < :mavericks
    depends_on "boost" => "c++11"
    depends_on "taglib" => "c++11"
  else
    depends_on "boost"
    depends_on "taglib"
  end

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j6" if ENV["CIRCLECI"]

    ENV.cxx11
    ENV.append "LDFLAGS", "-liconv" if OS.mac?
    ENV.append "BOOST_LIB_SUFFIX", "-mt"
    ENV.append "CXXFLAGS", "-D_XOPEN_SOURCE_EXTENDED"

    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--with-taglib",
      "--with-curl",
      "--enable-unicode",
    ]

    args << "--enable-outputs" if build.with? "outputs"
    args << "--enable-visualizer" if build.with? "visualizer"
    args << "--enable-clock" if build.with? "clock"

    if build.head?
      # Also runs configure
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ncmpcpp --version")
  end
end
