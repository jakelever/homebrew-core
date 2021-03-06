class Xmlstarlet < Formula
  desc "XML command-line utilities"
  homepage "http://xmlstar.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/xmlstar/xmlstarlet/1.6.1/xmlstarlet-1.6.1.tar.gz"
  sha256 "15d838c4f3375332fd95554619179b69e4ec91418a3a5296e7c631b7ed19e7ca"

  bottle do
    cellar :any_skip_relocation
    sha256 "2d9a9b5f875b91c78378e7f3df12595528d8e4b9ec9e321131b7f9f78f30acd8" => :el_capitan
    sha256 "525eafe6cab96cc6e04fef756e25316119b3c96cb61e5f7f51770cd062ad1bec" => :yosemite
    sha256 "7004b98b4dd9195a35f736ba3f6282369a2c63397a710056c5d1ae71d149fa3a" => :mavericks
    sha256 "88b419a7af11d19f44e0450b8f50ae1c56a75d4b04124ad612e2ea15db557f3f" => :x86_64_linux
  end

  depends_on "libxslt" unless OS.mac?

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
    bin.install_symlink "xml" => "xmlstarlet"
  end
end
