{
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  curl,
  dbus,
  dpkg,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libdrm,
  libGL,
  libnotify,
  libsecret,
  libuuid,
  libxcb,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,
  stdenv,
  systemd,
  wrapGAppsHook3,
  xorg,
}:

let
  version = "1.46.0";

  rpath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libnotify
    libsecret
    libuuid
    libxcb
    libxkbcommon
    libgbm
    nspr
    nss
    pango
    stdenv.cc.cc
    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxkbfile
    xorg.libxshmfence
    (lib.getLib stdenv.cc.cc)
  ];

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://downloads.mongodb.com/compass/mongodb-compass_${version}_amd64.deb";
        hash = "sha256-cwhYiV5G8GRBT7MST20MPUxEMQM1mzxlLUfzGO6jv10=";
      }
    else
      throw "MongoDB compass is not supported on ${stdenv.hostPlatform.system}";
  # NOTE While MongoDB Compass is available to darwin, I do not have resources to test it
  # Feel free to make a PR adding support if desired

in
stdenv.mkDerivation {
  pname = "mongodb-compass";
  inherit version;

  inherit src;

  buildInputs = [
    dpkg
    wrapGAppsHook3
    gtk3
  ];
  dontUnpack = true;

  buildCommand = ''
    IFS=$'\n'

    # The deb file contains a setuid binary, so 'dpkg -x' doesn't work here
    dpkg --fsys-tarfile $src | tar --extract

    mkdir -p $out
    mv usr/* $out

    # cp -av $out/usr/* $out
    rm -rf $out/share/lintian

    # The node_modules are bringing in non-linux files/dependencies
    find $out -name "*.app" -exec rm -rf {} \; || true
    find $out -name "*.dll" -delete
    find $out -name "*.exe" -delete

    # Otherwise it looks "suspicious"
    chmod -R g-w $out

    for file in `find $out -type f -perm /0111 -o -name \*.so\*`; do
      echo "Manipulating file: $file"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/mongodb-compass "$file" || true
    done

    wrapGAppsHook $out/bin/mongodb-compass
  '';

  meta = {
    description = "GUI for MongoDB";
    maintainers = with lib.maintainers; [
      bryanasdev000
      friedow
    ];
    homepage = "https://github.com/mongodb-js/compass";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.sspl;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mongodb-compass";
  };
}
