{
  lib,
  stdenv,
  fetchFromGitLab,
}:

let
  # These settings are found in the Makefile, but there seems to be no
  # way to select one or the other setting other than editing the file
  # manually, so we have to duplicate the know how here.
  systemFlags =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      CFLAGS="-O2 -Wall -fomit-frame-pointer -no-cpp-precomp"
      LDFLAGS=
    ''
    + lib.optionalString stdenv.hostPlatform.isCygwin ''
      CFLAGS="-O2 -Wall -fomit-frame-pointer"
      LDFLAGS=-s
      TREE_DEST=tree.exe
    ''
    + lib.optionalString (stdenv.hostPlatform.isFreeBSD || stdenv.hostPlatform.isOpenBSD) ''
      CFLAGS="-O2 -Wall -fomit-frame-pointer"
      LDFLAGS=-s
    ''; # use linux flags by default
in
stdenv.mkDerivation rec {
  pname = "tree";
  version = "2.2.1";

  src = fetchFromGitLab {
    owner = "OldManProgrammer";
    repo = "unix-tree";
    rev = version;
    hash = "sha256-sC3XdZWJSXyCIYr/Y41ogz5bNBTfwKjOFtYwhayXPhY=";
  };

  preConfigure = ''
    makeFlagsArray+=(${systemFlags})
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    homepage = "https://oldmanprogrammer.net/source.php?dir=projects/tree";
    description = "Command to produce a depth indented directory listing";
    license = licenses.gpl2Plus;
    longDescription = ''
      Tree is a recursive directory listing command that produces a
      depth indented listing of files, which is colorized ala dircolors if
      the LS_COLORS environment variable is set and output is to tty.
    '';
    platforms = platforms.all;
    maintainers = with maintainers; [ nickcao ];
    mainProgram = "tree";
  };
}
