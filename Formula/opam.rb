class Opam < Formula
  desc "Package manager for OCaml"
  homepage "https://opam.ocaml.org"
  url "https://github.com/ocaml/opam/archive/1.2.2.tar.gz"
  sha256 "3e4a05df6ff8deecba019d885ebe902eb933acb6e2fc7784ffee1ee14871e36a"
  revision 2
  head "https://github.com/ocaml/opam.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "833e78a6f35f9a3e9374d88b558f5137ba69d0661a15b1737ba103350330b1bb" => :el_capitan
    sha256 "38d74f1eb643e7db9405a142b9067e5ae35e5b0394986abdd7b25c32fc6a9977" => :yosemite
    sha256 "c5cb841262a592cf43f152dc664e5268ab3d24da9e0a18974b376e0348fbf460" => :mavericks
    sha256 "b5b4c5a94fe67a5876abfb58a819b21bd596bfa28f4e560cec8e43edb544ae6c" => :x86_64_linux
  end

  depends_on "ocaml" => :recommended
  depends_on "camlp4" => :recommended if build.with? "ocaml"
  depends_on "homebrew/dupes/unzip" unless OS.mac?

  # aspcud has a fairly large buildtime dep tree, and uses gringo,
  # which requires C++11 and is inconvenient to install pre-10.8
  if MacOS.version > 10.7
    depends_on "aspcud" => :recommended
  else
    depends_on "aspcud" => :optional
  end

  needs :cxx11 if build.with? "aspcud"

  resource "cudf" do
    url "https://gforge.inria.fr/frs/download.php/file/33593/cudf-0.7.tar.gz"
    sha256 "92c8a9ed730bbac73f3513abab41127d966c9b9202ab2aaffcd02358c030a701"
  end

  resource "extlib" do
    url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ocaml-extlib/extlib-1.5.3.tar.gz"
    sha256 "c095eef4202a8614ff1474d4c08c50c32d6ca82d1015387785cf03d5913ec021"
  end

  resource "ocaml-re" do
    url "https://github.com/ocaml/ocaml-re/archive/ocaml-re-1.2.0.tar.gz"
    sha256 "a34dd9d6136731436a963bbab5c4bbb16e5d4e21b3b851d34887a3dec451999f"
  end

  resource "ocamlgraph" do
    url "http://ocamlgraph.lri.fr/download/ocamlgraph-1.8.5.tar.gz"
    sha256 "d167466435a155c779d5ec25b2db83ad851feb42ebc37dca8ffa345ddaefb82f"
  end

  resource "dose3" do
    url "https://gforge.inria.fr/frs/download.php/file/34277/dose3-3.3.tar.gz"
    sha256 "8dc4dae9b1a81bb3a42abb283df785ba3eb00ade29b13875821c69f03e00680e"
  end

  resource "cmdliner" do
    url "http://erratique.ch/software/cmdliner/releases/cmdliner-0.9.7.tbz"
    sha256 "9c19893cffb5d3c3469ee0cce85e3eeeba17d309b33b9ace31aba06f68f0bf7a"
  end

  resource "uutf" do
    url "http://erratique.ch/software/uutf/releases/uutf-0.9.3.tbz"
    sha256 "1f364f89b1179e5182a4d3ad8975f57389d45548735d19054845e06a27107877"
  end

  resource "jsonm" do
    url "http://erratique.ch/software/jsonm/releases/jsonm-0.9.1.tbz"
    sha256 "3fd4dca045d82332da847e65e981d8b504883571d299a3f7e71447d46bc65f73"
  end

  def install
    ENV.deparallelize

    if build.without? "ocaml"
      system "make", "cold", "CONFIGURE_ARGS=--prefix #{prefix} --mandir #{man}"
      ENV.prepend_path "PATH", "#{buildpath}/bootstrap/ocaml/bin"
    else
      # We put the compressed external libraries where the build
      # expects to find them, thus tricking it into believing that it
      # already downloaded the necessary files.
      resources.each do |r|
        r.verify_download_integrity(r.fetch)
        original_name = r.cached_download.basename.sub(/^#{Regexp.escape(name)}--/, "")
        cp r.cached_download, buildpath/"src_ext/#{original_name}"
      end

      system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
      system "make", "lib-ext"
      system "make"
    end
    system "make", "man"
    system "make", "install"

    bash_completion.install "shell/opam_completion.sh"
    zsh_completion.install "shell/opam_completion_zsh.sh" => "_opam"
  end

  def caveats; <<-EOS.undent
    OPAM uses ~/.opam by default for its package database, so you need to
    initialize it first by running (as a normal user):

    $  opam init

    Run the following to initialize your environment variables:

    $  eval `opam config env`

    To export the needed variables every time, add them to your dotfiles.
      * On Bash, add them to `~/.bash_profile`.
      * On Zsh, add them to `~/.zprofile` or `~/.zshrc` instead.

    Documentation and tutorials are available at https://opam.ocaml.org, or
    via "man opam" and "opam --help".
    EOS
  end

  test do
    system bin/"opam", "--help"
  end
end
