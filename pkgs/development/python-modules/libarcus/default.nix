{
  lib,
  buildPythonPackage,
  python,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  sip,
  protobuf,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "libarcus";
  version = "5.2.2";
  format = "other";

  src = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "libArcus";
    rev = version;
    sha256 = "sha256-azQMrD56nKPjdtPZwV+MqHHYnQaAq6jRUWhOwhyVbZs=";
  };

  patches = [
    # Imported from Alpine:
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/libarcus/cmake-build.patch?id=ad078141cb02378fe42aedea4271f4beb2fd2f01";
      name = "libarcus-cmake-build.patch";
      sha256 = "0v0cxhaazq29psq9idcv16ngvp30j3h5xghx8vb9n79zl1a9b82n";
    })
    # Imported from Alpine:
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/libarcus/ArcusConfig.patch?id=ad078141cb02378fe42aedea4271f4beb2fd2f01";
      name = "libarcus-ArcusConfig.patch";
      sha256 = "1yq4a3r6q3bq22adsmzh9048q6db9qrwp1cl51xp1x7j9b9cxgda";
    })
    # Imported from Alpine:
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/libarcus/gcc15-cstdint.patch?id=e543192e306699eeaffc483c419ee0993f490be4";
      name = "libarcus-gcc15-cstdint.patch";
      sha256 = "sha256-z7UNRmBLxPp2tHJJSgORqOO9cKHVQc5j6ZfoeXJtZRY=";
    })
  ];

  disabled = pythonOlder "3.4";

  propagatedBuildInputs = [ sip ];
  nativeBuildInputs = [ cmake ];
  buildInputs = [ protobuf ];

  cmakeFlags = [
    # The `libarcus-cmake-build.patch` above adds a line with `set_target_properties()` that requires this.
    "-DARCUS_VERSION=${version}"
  ];

  meta = with lib; {
    description = "Communication library between internal components for Ultimaker software";
    homepage = "https://github.com/Ultimaker/libArcus";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
