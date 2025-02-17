{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
}:

self: super:

{
  automat = super.automat.overridePythonAttrs (
    old: rec {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.m2r ];
    }
  );

  ansible = super.ansible.overridePythonAttrs (
    old: {

      prePatch = pkgs.python.pkgs.ansible.prePatch or "";

      postInstall = pkgs.python.pkgs.ansible.postInstall or "";

      # Inputs copied from nixpkgs as ansible doesn't specify it's dependencies
      # in a correct manner.
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self.pycrypto
        self.paramiko
        self.jinja2
        self.pyyaml
        self.httplib2
        self.six
        self.netaddr
        self.dnspython
        self.jmespath
        self.dopy
        self.ncclient
      ];
    }
  );

  ansible-lint = super.ansible-lint.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.setuptools-scm-git-archive ];
      preBuild = ''
        export HOME=$(mktemp -d)
      '';
    }
  );

  astroid = super.astroid.overridePythonAttrs (
    old: rec {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      doCheck = false;
    }
  );

  av = super.av.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        pkgs.pkgconfig
      ];
      buildInputs = old.buildInputs ++ [ pkgs.ffmpeg_4 ];
    }
  );

  bcrypt = super.bcrypt.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ pkgs.libffi ];
    }
  );

  cairocffi = super.cairocffi.overridePythonAttrs (
    old: {
      inherit (pkgs.python3.pkgs.cairocffi) patches;
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  cairosvg = super.cairosvg.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  cssselect2 = super.cssselect2.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  cffi =
    # cffi is bundled with pypy
    if self.python.implementation == "pypy" then null else
    (
      super.cffi.overridePythonAttrs (
        old: {
          buildInputs = old.buildInputs or [ ] ++ [ pkgs.libffi ];
        }
      )
    );

  cftime = super.cftime.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.cython
      ];
    }
  );

  colour = super.colour.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.d2to1 ];
    }
  );

  configparser = super.configparser.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.toml
      ];

      postPatch = ''
        substituteInPlace setup.py --replace 'setuptools.setup()' 'setuptools.setup(version="${old.version}")'
      '';
    }
  );

  cryptography = super.cryptography.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs or [ ]
        ++ stdenv.lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) self.python.pythonForBuild.pkgs.cffi;
      buildInputs = old.buildInputs ++ [ pkgs.openssl ];
    }
  );

  datadog-lambda = super.datadog-lambda.overridePythonAttrs (old: {
    postPatch = ''
      substituteInPlace setup.py --replace "setuptools==" "setuptools>="
    '';
    buildInputs = old.buildInputs ++ [ self.setuptools ];
  });

  ddtrace = super.ddtrace.overridePythonAttrs (old: {
    buildInputs = old.buildInputs ++
      (pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.IOKit ]) ++ [ self.cython ];
  });

  dictdiffer = super.dictdiffer.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.setuptools ];
    }
  );

  django = (
    super.django.overridePythonAttrs (
      old: {
        propagatedNativeBuildInputs = (old.propagatedNativeBuildInputs or [ ])
          ++ [ pkgs.gettext ];
      }
    )
  );

  django-bakery = super.django-bakery.overridePythonAttrs (
    old: {
      configurePhase = ''
        if ! test -e LICENSE; then
          touch LICENSE
        fi
      '' + (old.configurePhase or "");
    }
  );

  dlib = super.dlib.overridePythonAttrs (
    old: {
      # Parallel building enabled
      inherit (pkgs.python.pkgs.dlib) patches;

      enableParallelBuilding = true;
      dontUseCmakeConfigure = true;

      nativeBuildInputs = old.nativeBuildInputs ++ pkgs.dlib.nativeBuildInputs;
      buildInputs = old.buildInputs ++ pkgs.dlib.buildInputs;
    }
  );

  # Environment markers are not always included (depending on how a dep was defined)
  enum34 = if self.pythonAtLeast "3.4" then null else super.enum34;

  eth-hash = super.eth-hash.overridePythonAttrs {
    preConfigure = ''
      substituteInPlace setup.py --replace \'setuptools-markdown\' ""
    '';
  };

  eth-keyfile = super.eth-keyfile.overridePythonAttrs {
    preConfigure = ''
      substituteInPlace setup.py --replace \'setuptools-markdown\' ""
    '';
  };

  eth-keys = super.eth-keys.overridePythonAttrs {
    preConfigure = ''
      substituteInPlace setup.py --replace \'setuptools-markdown\' ""
    '';
  };

  faker = super.faker.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      doCheck = false;
    }
  );

  fancycompleter = super.fancycompleter.overridePythonAttrs (
    old: {
      postPatch = ''
        substituteInPlace setup.py \
          --replace 'setup_requires="setupmeta"' 'setup_requires=[]' \
          --replace 'versioning="devcommit"' 'version="${old.version}"'
      '';
    }
  );

  fastparquet = super.fastparquet.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  grandalf = super.grandalf.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      doCheck = false;
    }
  );

  h3 = super.h3.overridePythonAttrs (
    old: {
      preBuild = (old.preBuild or "") + ''
        substituteInPlace h3/h3.py \
          --replace "'{}/{}'.format(_dirname, libh3_path)" '"${pkgs.h3}/lib/libh3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}"'
      '';
    }
  );

  h5py = super.h5py.overridePythonAttrs (
    old:
    if old.format != "wheel" then rec {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkgconfig ];
      buildInputs = old.buildInputs ++ [ pkgs.hdf5 self.pkgconfig self.cython ];
      configure_flags = "--hdf5=${pkgs.hdf5}";
      postConfigure = ''
        ${self.python.executable} setup.py configure ${configure_flags}
      '';
    } else old
  );

  horovod = super.horovod.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.openmpi ];
    }
  );

  imagecodecs = super.imagecodecs.overridePythonAttrs (
    old: {
      patchPhase = ''
        substituteInPlace setup.py \
          --replace "/usr/include/openjpeg-2.3" \
                    "${pkgs.openjpeg.dev}/include/openjpeg-2.3"
        substituteInPlace setup.py \
          --replace "/usr/include/jxrlib" \
                    "$out/include/libjxr"
        substituteInPlace imagecodecs/_zopfli.c \
          --replace '"zopfli/zopfli.h"' \
                    '<zopfli.h>'
        substituteInPlace imagecodecs/_zopfli.c \
          --replace '"zopfli/zlib_container.h"' \
                    '<zlib_container.h>'
        substituteInPlace imagecodecs/_zopfli.c \
          --replace '"zopfli/gzip_container.h"' \
                    '<gzip_container.h>'
      '';

      preBuild = ''
        mkdir -p $out/include/libjxr
        ln -s ${pkgs.jxrlib}/include/libjxr/**/* $out/include/libjxr

      '';

      buildInputs = old.buildInputs ++ [
        # Commented out packages are declared required, but not actually
        # needed to build. They are not yet packaged for nixpkgs.
        # bitshuffle
        pkgs.brotli
        # brunsli
        pkgs.bzip2
        pkgs.c-blosc
        # charls
        pkgs.giflib
        pkgs.jxrlib
        pkgs.lcms
        pkgs.libaec
        pkgs.libaec
        pkgs.libjpeg_turbo
        # liblzf
        # liblzma
        pkgs.libpng
        pkgs.libtiff
        pkgs.libwebp
        pkgs.lz4
        pkgs.openjpeg
        pkgs.snappy
        # zfp
        pkgs.zopfli
        pkgs.zstd
        pkgs.zlib
      ];
    }
  );

  # importlib-metadata has an incomplete dependency specification
  importlib-metadata = super.importlib-metadata.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ lib.optional self.python.isPy2 self.pathlib2;
    }
  );

  intreehooks = super.intreehooks.overridePythonAttrs (
    old: {
      doCheck = false;
    }
  );

  isort = super.isort.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.setuptools ];
    }
  );

  # disable the removal of pyproject.toml, required because of setuptools_scm
  jaraco-functools = super.jaraco-functools.overridePythonAttrs (
    old: {
      dontPreferSetupPy = true;
    }
  );

  jira = super.jira.overridePythonAttrs (
    old: {
      inherit (pkgs.python3Packages.jira) patches;
      buildInputs = old.buildInputs ++ [
        self.pytestrunner
        self.cryptography
        self.pyjwt
      ];
    }
  );

  jsonpickle = super.jsonpickle.overridePythonAttrs (
    old: {
      dontPreferSetupPy = true;
    }
  );

  jupyter = super.jupyter.overridePythonAttrs (
    old: rec {
      # jupyter is a meta-package. Everything relevant comes from the
      # dependencies. It does however have a jupyter.py file that conflicts
      # with jupyter-core so this meta solves this conflict.
      meta.priority = 100;
    }
  );

  keyring = super.keyring.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.toml
      ];
      postPatch = ''
        substituteInPlace setup.py --replace 'setuptools.setup()' 'setuptools.setup(version="${old.version}")'
      '';
    }
  );

  kiwisolver = super.kiwisolver.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.cppy
      ];
    }
  );

  lap = super.lap.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self.numpy
      ];
    }
  );

  libvirt-python = super.libvirt-python.overridePythonAttrs ({ nativeBuildInputs ? [ ], ... }: {
    nativeBuildInputs = nativeBuildInputs ++ [ pkgs.pkgconfig ];
    propagatedBuildInputs = [ pkgs.libvirt ];
  });

  llvmlite = super.llvmlite.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.llvm ];

      # Disable static linking
      # https://github.com/numba/llvmlite/issues/93
      postPatch = ''
        substituteInPlace ffi/Makefile.linux --replace "-static-libstdc++" ""

        substituteInPlace llvmlite/tests/test_binding.py --replace "test_linux" "nope"
      '';

      # Set directory containing llvm-config binary
      preConfigure = ''
        export LLVM_CONFIG=${pkgs.llvm}/bin/llvm-config
      '';

      __impureHostDeps = pkgs.stdenv.lib.optionals pkgs.stdenv.isDarwin [ "/usr/lib/libm.dylib" ];

      passthru = old.passthru // { llvm = pkgs.llvm; };
    }
  );

  lockfile = super.lockfile.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.pbr ];
    }
  );

  lxml = super.lxml.overridePythonAttrs (
    old: {
      nativeBuildInputs = with pkgs; old.nativeBuildInputs ++ [ pkgconfig libxml2.dev libxslt.dev ];
      buildInputs = with pkgs; old.buildInputs ++ [ libxml2 libxslt ];
    }
  );

  markupsafe = super.markupsafe.overridePythonAttrs (
    old: {
      src = old.src.override { pname = builtins.replaceStrings [ "markupsafe" ] [ "MarkupSafe" ] old.pname; };
    }
  );

  matplotlib = super.matplotlib.overridePythonAttrs (
    old:
    let
      enableGhostscript = old.passthru.enableGhostscript or false;
      enableGtk3 = old.passthru.enableTk or false;
      enableQt = old.passthru.enableQt or false;
      enableTk = old.passthru.enableTk or false;

      inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
    in
    {
      NIX_CFLAGS_COMPILE = stdenv.lib.optionalString stdenv.isDarwin "-I${pkgs.libcxx}/include/c++/v1";

      XDG_RUNTIME_DIR = "/tmp";

      buildInputs = old.buildInputs
        ++ lib.optional enableGhostscript pkgs.ghostscript
        ++ lib.optional stdenv.isDarwin [ Cocoa ];

      nativeBuildInputs = old.nativeBuildInputs ++ [
        pkgs.pkgconfig
      ];

      postPatch = ''
        cat > setup.cfg <<EOF
        [libs]
        system_freetype = True
        EOF
      '';

      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        pkgs.libpng
        pkgs.freetype
      ]
        ++ stdenv.lib.optionals enableGtk3 [ pkgs.cairo self.pycairo pkgs.gtk3 pkgs.gobject-introspection self.pygobject3 ]
        ++ stdenv.lib.optionals enableTk [ pkgs.tcl pkgs.tk self.tkinter pkgs.libX11 ]
        ++ stdenv.lib.optionals enableQt [ self.pyqt5 ]
      ;

      inherit (super.matplotlib) patches;
    }
  );

  # Calls Cargo at build time for source builds and is really tricky to package
  maturin = super.maturin.override {
    preferWheel = true;
  };

  mccabe = super.mccabe.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      doCheck = false;
    }
  );

  mip = super.mip.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.autoPatchelfHook ];

      buildInputs = old.buildInputs ++ [ pkgs.zlib self.cppy ];
    }
  );

  molecule =
    if lib.versionOlder super.molecule.version "3.0.0" then
      (super.molecule.overridePythonAttrs (
        old: {
          patches = (old.patches or [ ]) ++ [
            # Fix build with more recent setuptools versions
            (pkgs.fetchpatch {
              url = "https://github.com/ansible-community/molecule/commit/c9fee498646a702c77b5aecf6497cff324acd056.patch";
              sha256 = "1g1n45izdz0a3c9akgxx14zhdw6c3dkb48j8pq64n82fa6ndl1b7";
              excludes = [ "pyproject.toml" ];
            })
          ];
          buildInputs = old.buildInputs ++ [ self.setuptools-scm-git-archive ];
        }
      )) else
      super.molecule.overridePythonAttrs (old: {
        buildInputs = old.buildInputs ++ [ self.setuptools-scm-git-archive ];
      });

  mongomock = super.mongomock.overridePythonAttrs (oa: {
    buildInputs = oa.buildInputs ++ [ self.pbr ];
  });

  mpi4py = super.mpi4py.overridePythonAttrs (
    old:
    let
      cfg = pkgs.writeTextFile {
        name = "mpi.cfg";
        text = (
          lib.generators.toINI
            { }
            {
              mpi = {
                mpicc = "${pkgs.openmpi.outPath}/bin/mpicc";
              };
            }
        );
      };
    in
    {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.openmpi ];
      enableParallelBuilding = true;
      preBuild = ''
        ln -sf ${cfg} mpi.cfg
      '';
    }
  );

  multiaddr = super.multiaddr.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  netcdf4 = super.netcdf4.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.cython
      ];

      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        pkgs.zlib
        pkgs.netcdf
        pkgs.hdf5
        pkgs.curl
        pkgs.libjpeg
      ];

      # Variables used to configure the build process
      USE_NCCONFIG = "0";
      HDF5_DIR = lib.getDev pkgs.hdf5;
      NETCDF4_DIR = pkgs.netcdf;
      CURL_DIR = pkgs.curl.dev;
      JPEG_DIR = pkgs.libjpeg.dev;
    }
  );

  numpy = super.numpy.overridePythonAttrs (
    old:
    let
      blas = old.passthru.args.blas or pkgs.openblasCompat;
      blasImplementation = lib.nameFromURL blas.name "-";
      cfg = pkgs.writeTextFile {
        name = "site.cfg";
        text = (
          lib.generators.toINI
            { }
            {
              ${blasImplementation} = {
                include_dirs = "${blas}/include";
                library_dirs = "${blas}/lib";
              } // lib.optionalAttrs (blasImplementation == "mkl") {
                mkl_libs = "mkl_rt";
                lapack_libs = "";
              };
            }
        );
      };
    in
    {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.gfortran ];
      buildInputs = old.buildInputs ++ [ blas self.cython ];
      enableParallelBuilding = true;
      preBuild = ''
        ln -s ${cfg} site.cfg
      '';
      passthru = old.passthru // {
        blas = blas;
        inherit blasImplementation cfg;
      };
    }
  );

  openexr = super.openexr.overridePythonAttrs (
    old: rec {
      buildInputs = old.buildInputs ++ [ pkgs.openexr pkgs.ilmbase ];
      NIX_CFLAGS_COMPILE = [ "-I${pkgs.openexr.dev}/include/OpenEXR" "-I${pkgs.ilmbase.dev}/include/OpenEXR" ];
    }
  );

  parsel = super.parsel.overridePythonAttrs (
    old: rec {
      nativeBuildInputs = old.nativeBuildInputs ++ [ self.pytest-runner ];
    }
  );

  peewee = super.peewee.overridePythonAttrs (
    old:
    let
      withPostgres = old.passthru.withPostgres or false;
      withMysql = old.passthru.withMysql or false;
    in
    {
      buildInputs = old.buildInputs or [ ] ++ [ pkgs.sqlite ];
      propagatedBuildInputs = old.propagatedBuildInputs or [ ]
        ++ lib.optional withPostgres self.psycopg2
        ++ lib.optional withMysql self.mysql-connector;
    }
  );

  pillow = super.pillow.overridePythonAttrs (
    old: {
      nativeBuildInputs = [ pkgs.pkgconfig ] ++ old.nativeBuildInputs;
      buildInputs = with pkgs; [ freetype libjpeg zlib libtiff libwebp tcl lcms2 ] ++ old.buildInputs;
    }
  );

  poetry-core = super.poetry-core.overridePythonAttrs (old: {
    # "Vendor" dependencies (for build-system support)
    postPatch = ''
      echo "import sys" >> poetry/__init__.py
      for path in $propagatedBuildInputs; do
          echo "sys.path.insert(0, \"$path\")" >> poetry/__init__.py
      done
    '';

    # Propagating dependencies leads to issues downstream
    # We've already patched poetry to prefer "vendored" dependencies
    postFixup = ''
      rm $out/nix-support/propagated-build-inputs
    '';
  });

  # disable the removal of pyproject.toml, required because of setuptools_scm
  portend = super.portend.overridePythonAttrs (
    old: {
      dontPreferSetupPy = true;
    }
  );

  psycopg2 = super.psycopg2.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs
        ++ lib.optional stdenv.isDarwin pkgs.openssl;
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.postgresql ];
    }
  );

  psycopg2-binary = super.psycopg2-binary.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs
        ++ lib.optional stdenv.isDarwin pkgs.openssl;
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.postgresql ];
    }
  );

  pyarrow =
    if lib.versionAtLeast super.pyarrow.version "0.16.0" then
      super.pyarrow.overridePythonAttrs
        (
          old:
          let
            parseMinor = drv: lib.concatStringsSep "." (lib.take 2 (lib.splitVersion drv.version));

            # Starting with nixpkgs revision f149c7030a7, pyarrow takes "python3" as an argument
            # instead of "python". Below we inspect function arguments to maintain compatibilitiy.
            _arrow-cpp = pkgs.arrow-cpp.override (
              builtins.intersectAttrs
                (lib.functionArgs pkgs.arrow-cpp.override)
                { python = self.python; python3 = self.python; }
            );

            ARROW_HOME = _arrow-cpp;
            arrowCppVersion = parseMinor pkgs.arrow-cpp;
            pyArrowVersion = parseMinor super.pyarrow;
            errorMessage = "arrow-cpp version (${arrowCppVersion}) mismatches pyarrow version (${pyArrowVersion})";
          in
          if arrowCppVersion != pyArrowVersion then throw errorMessage else {

            nativeBuildInputs = old.nativeBuildInputs ++ [
              self.cython
              pkgs.pkgconfig
              pkgs.cmake
            ];

            preBuild = ''
              export PYARROW_PARALLEL=$NIX_BUILD_CORES
            '';

            PARQUET_HOME = _arrow-cpp;
            inherit ARROW_HOME;

            buildInputs = old.buildInputs ++ [
              pkgs.arrow-cpp
            ];

            PYARROW_BUILD_TYPE = "release";
            PYARROW_WITH_PARQUET = true;
            PYARROW_CMAKE_OPTIONS = [
              "-DCMAKE_INSTALL_RPATH=${ARROW_HOME}/lib"

              # This doesn't use setup hook to call cmake so we need to workaround #54606
              # ourselves
              "-DCMAKE_POLICY_DEFAULT_CMP0025=NEW"
            ];

            dontUseCmakeConfigure = true;
          }
        ) else
      super.pyarrow.overridePythonAttrs (
        old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            self.cython
          ];
        }
      );

  pycairo = (
    drv: (
      drv.overridePythonAttrs (
        _: {
          format = "other";
        }
      )
    ).overridePythonAttrs (
      old: {

        nativeBuildInputs = old.nativeBuildInputs ++ [
          pkgs.meson
          pkgs.ninja
          pkgs.pkgconfig
        ];

        propagatedBuildInputs = old.propagatedBuildInputs ++ [
          pkgs.cairo
          pkgs.xlibsWrapper
        ];

        mesonFlags = [ "-Dpython=${if self.isPy3k then "python3" else "python"}" ];
      }
    )
  )
    super.pycairo;

  pycocotools = super.pycocotools.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        self.cython
        self.numpy
      ];
    }
  );

  pygame = super.pygame.overridePythonAttrs (
    old: rec {
      nativeBuildInputs = [
        pkgs.pkg-config
        pkgs.SDL
      ];

      buildInputs = [
        pkgs.SDL
        pkgs.SDL_image
        pkgs.SDL_mixer
        pkgs.SDL_ttf
        pkgs.libpng
        pkgs.libjpeg
        pkgs.portmidi
        pkgs.xorg.libX11
        pkgs.freetype
      ];

      # Tests fail because of no audio device and display.
      doCheck = false;
      preConfigure = ''
                sed \
                  -e "s/origincdirs = .*/origincdirs = []/" \
                  -e "s/origlibdirs = .*/origlibdirs = []/" \
                  -e "/'\/lib\/i386-linux-gnu', '\/lib\/x86_64-linux-gnu']/d" \
                  -e "/\/include\/smpeg/d" \
                  -i buildconfig/config_unix.py
                ${lib.concatMapStrings
        (dep: ''
                  sed \
                    -e "/origincdirs =/a\        origincdirs += ['${lib.getDev dep}/include']" \
                    -e "/origlibdirs =/a\        origlibdirs += ['${lib.getLib dep}/lib']" \
                    -i buildconfig/config_unix.py
                '')
        buildInputs
                }
                LOCALBASE=/ ${self.python.interpreter} buildconfig/config.py
      '';
    }
  );

  pygobject = super.pygobject.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkgconfig ];
      buildInputs = old.buildInputs ++ [ pkgs.glib pkgs.gobject-introspection ];
    }
  );

  pylint = super.pylint.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
      doCheck = false;
    }
  );

  pyopenssl = super.pyopenssl.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ pkgs.openssl ];
    }
  );

  python-bugzilla = super.python-bugzilla.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        self.docutils
      ];
    }
  );

  python-ldap = super.python-ldap.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ pkgs.openldap pkgs.cyrus_sasl ];
    }
  );

  pytoml = super.pytoml.overridePythonAttrs (
    old: {
      doCheck = false;
    }
  );

  pyqt5 =
    let
      drv = super.pyqt5;
      withConnectivity = drv.passthru.args.withConnectivity or false;
      withMultimedia = drv.passthru.args.withMultimedia or false;
      withWebKit = drv.passthru.args.withWebKit or false;
      withWebSockets = drv.passthru.args.withWebSockets or false;
    in
    super.pyqt5.overridePythonAttrs (
      old: {
        format = "other";

        nativeBuildInputs = old.nativeBuildInputs ++ [
          pkgs.pkgconfig
          pkgs.qt5.qmake
          pkgs.xorg.lndir
          pkgs.qt5.qtbase
          pkgs.qt5.qtsvg
          pkgs.qt5.qtdeclarative
          pkgs.qt5.qtwebchannel
          # self.pyqt5-sip
          self.sip
        ]
          ++ lib.optional withConnectivity pkgs.qt5.qtconnectivity
          ++ lib.optional withMultimedia pkgs.qt5.qtmultimedia
          ++ lib.optional withWebKit pkgs.qt5.qtwebkit
          ++ lib.optional withWebSockets pkgs.qt5.qtwebsockets
        ;

        buildInputs = old.buildInputs ++ [
          pkgs.dbus
          pkgs.qt5.qtbase
          pkgs.qt5.qtsvg
          pkgs.qt5.qtdeclarative
          self.sip
        ]
          ++ lib.optional withConnectivity pkgs.qt5.qtconnectivity
          ++ lib.optional withWebKit pkgs.qt5.qtwebkit
          ++ lib.optional withWebSockets pkgs.qt5.qtwebsockets
        ;

        # Fix dbus mainloop
        patches = pkgs.python3.pkgs.pyqt5.patches or [ ];

        configurePhase = ''
          runHook preConfigure

          export PYTHONPATH=$PYTHONPATH:$out/${self.python.sitePackages}

          mkdir -p $out/${self.python.sitePackages}/dbus/mainloop
          ${self.python.executable} configure.py  -w \
            --confirm-license \
            --no-qml-plugin \
            --bindir=$out/bin \
            --destdir=$out/${self.python.sitePackages} \
            --stubsdir=$out/${self.python.sitePackages}/PyQt5 \
            --sipdir=$out/share/sip/PyQt5 \
            --designer-plugindir=$out/plugins/designer

          runHook postConfigure
        '';

        postInstall = ''
          ln -s ${self.pyqt5-sip}/${self.python.sitePackages}/PyQt5/sip.* $out/${self.python.sitePackages}/PyQt5/
          for i in $out/bin/*; do
            wrapProgram $i --prefix PYTHONPATH : "$PYTHONPATH"
          done

          # Let's make it a namespace package
          cat << EOF > $out/${self.python.sitePackages}/PyQt5/__init__.py
          from pkgutil import extend_path
          __path__ = extend_path(__path__, __name__)
          EOF
        '';

        installCheckPhase =
          let
            modules = [
              "PyQt5"
              "PyQt5.QtCore"
              "PyQt5.QtQml"
              "PyQt5.QtWidgets"
              "PyQt5.QtGui"
            ]
            ++ lib.optional withWebSockets "PyQt5.QtWebSockets"
            ++ lib.optional withWebKit "PyQt5.QtWebKit"
            ++ lib.optional withMultimedia "PyQt5.QtMultimedia"
            ++ lib.optional withConnectivity "PyQt5.QtConnectivity"
            ;
            imports = lib.concatMapStrings (module: "import ${module};") modules;
          in
          ''
            echo "Checking whether modules can be imported..."
            ${self.python.interpreter} -c "${imports}"
          '';

        doCheck = true;

        enableParallelBuilding = true;
      }
    );

  pytest-datadir = super.pytest-datadir.overridePythonAttrs (
    old: {
      postInstall = ''
        rm -f $out/LICENSE
      '';
    }
  );

  pytest = super.pytest.overridePythonAttrs (
    old: {
      doCheck = false;
    }
  );

  pytest-django = super.pytest-django.overridePythonAttrs (
    old: {
      postPatch = ''
        substituteInPlace setup.py --replace "'pytest>=3.6'," ""
        substituteInPlace setup.py --replace "'pytest>=3.6'" ""
      '';
    }
  );

  pytest-runner = super.pytest-runner or super.pytestrunner;

  python-jose = super.python-jose.overridePythonAttrs (
    old: {
      postPath = ''
        substituteInPlace setup.py --replace "'pytest-runner'," ""
        substituteInPlace setup.py --replace "'pytest-runner'" ""
      '';
    }
  );

  ffmpeg-python = super.ffmpeg-python.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  python-prctl = super.python-prctl.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        pkgs.libcap
      ];
    }
  );

  pyzmq = super.pyzmq.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkgconfig ];
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.zeromq ];
    }
  );

  rockset = super.rockset.overridePythonAttrs (
    old: rec {
      postPatch = ''
        cp ./setup_rockset.py ./setup.py
      '';
    }
  );

  scaleapi = super.scaleapi.overridePythonAttrs (
    old: {
      postPatch = ''
        substituteInPlace setup.py --replace "install_requires = ['requests>=2.4.2', 'enum34']" "install_requires = ['requests>=2.4.2']" || true
      '';
    }
  );

  pandas = super.pandas.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ self.cython ];
    }
  );

  panel = super.panel.overridePythonAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.nodejs ];
    }
  );

  # Pybind11 is an undeclared dependency of scipy that we need to pick from nixpkgs
  # Make it not fail with infinite recursion
  pybind11 = super.pybind11.overridePythonAttrs (
    old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
        "-DPYBIND11_TEST=off"
      ];
      doCheck = false; # Circular test dependency
    }
  );

  rlp = super.rlp.overridePythonAttrs {
    preConfigure = ''
      substituteInPlace setup.py --replace \'setuptools-markdown\' ""
    '';
  };

  scipy = super.scipy.overridePythonAttrs (
    old:
    if old.format != "wheel" then {
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.gfortran ];
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.pybind11 ];
      setupPyBuildFlags = [ "--fcompiler='gnu95'" ];
      enableParallelBuilding = true;
      buildInputs = old.buildInputs ++ [ self.numpy.blas ];
      preConfigure = ''
        sed -i '0,/from numpy.distutils.core/s//import setuptools;from numpy.distutils.core/' setup.py
        export NPY_NUM_BUILD_JOBS=$NIX_BUILD_CORES
      '';
      preBuild = ''
        ln -s ${self.numpy.cfg} site.cfg
      '';
    } else old
  );

  scikit-learn = super.scikit-learn.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [
        pkgs.gfortran
        pkgs.glibcLocales
      ] ++ lib.optionals stdenv.cc.isClang [
        pkgs.llvmPackages.openmp
      ];

      nativeBuildInputs = old.nativeBuildInputs ++ [
        self.cython
      ];

      enableParallelBuilding = true;
    }
  );

  shapely = super.shapely.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ pkgs.geos self.cython ];
      inherit (pkgs.python3.pkgs.shapely) patches GEOS_LIBRARY_PATH;
    }
  );

  shellingham =
    if lib.versionAtLeast super.shellingham.version "1.3.2" then
      (
        super.shellingham.overridePythonAttrs (
          old: {
            format = "pyproject";
          }
        )
      ) else super.shellingham;

  tables = super.tables.overridePythonAttrs (
    old: {
      HDF5_DIR = "${pkgs.hdf5}";
      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkgconfig ];
      propagatedBuildInputs = old.nativeBuildInputs ++ [ pkgs.hdf5 self.numpy self.numexpr ];
    }
  );

  # disable the removal of pyproject.toml, required because of setuptools_scm
  tempora = super.tempora.overridePythonAttrs (
    old: {
      dontPreferSetupPy = true;
    }
  );

  tensorflow = super.tensorflow.overridePythonAttrs (
    old: {
      postInstall = ''
        rm $out/bin/tensorboard
      '';
    }
  );

  tensorpack = super.tensorpack.overridePythonAttrs (
    old: {
      postPatch = ''
        substituteInPlace setup.cfg --replace "# will call find_packages()" ""
      '';
    }
  );

  tinycss2 = super.tinycss2.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  torch = lib.makeOverridable
    ({ enableCuda ? false
     , cudatoolkit ? pkgs.cudatoolkit_10_1
     , pkg ? super.torch
     }: pkg.overrideAttrs (old:
      {
        preConfigure =
          if (!enableCuda) then ''
            export USE_CUDA=0
          '' else ''
            export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${cudatoolkit}/targets/x86_64-linux/lib"
          '';
        preFixup = lib.optionalString (!enableCuda) ''
          # For some reason pytorch retains a reference to libcuda even if it
          # is explicitly disabled with USE_CUDA=0.
          find $out -name "*.so" -exec ${pkgs.patchelf}/bin/patchelf --remove-needed libcuda.so.1 {} \;
        '';
        buildInputs = old.buildInputs ++ lib.optionals enableCuda [
          pkgs.linuxPackages.nvidia_x11
          pkgs.nccl.dev
          pkgs.nccl.out
        ];
        propagatedBuildInputs = [
          super.numpy
          super.future
        ];
      })
    )
    { };

  typeguard = super.typeguard.overridePythonAttrs (old: {
    postPatch = ''
      substituteInPlace setup.py \
        --replace 'setup()' 'setup(version="${old.version}")'
    '';
  });

  # nix uses a dash, poetry uses an underscore
  typing_extensions = super.typing_extensions or self.typing-extensions;

  urwidtrees = super.urwidtrees.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self.urwid
      ];
    }
  );

  vose-alias-method = super.vose-alias-method.overridePythonAttrs (
    old: {
      postInstall = ''
        rm -f $out/LICENSE
      '';
    }
  );

  vispy = super.vispy.overrideAttrs (
    old: {
      inherit (pkgs.python3.pkgs.vispy) patches;
      nativeBuildInputs = old.nativeBuildInputs ++ [
        self.cython
        self.setuptools-scm-git-archive
      ];
    }
  );

  uvloop = super.uvloop.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ lib.optionals stdenv.isDarwin [
        pkgs.darwin.apple_sdk.frameworks.ApplicationServices
        pkgs.darwin.apple_sdk.frameworks.CoreServices
      ];
    }
  );


  # Stop infinite recursion by using bootstrapped pkg from nixpkgs
  bootstrapped-pip = super.bootstrapped-pip.override {
    wheel = (pkgs.python3.pkgs.override {
      python = self.python;
    }).wheel;
  };

  weasyprint = super.weasyprint.overridePythonAttrs (
    old: {
      inherit (pkgs.python3.pkgs.weasyprint) patches;
      buildInputs = old.buildInputs ++ [ self.pytest-runner ];
    }
  );

  web3 = super.web3.overridePythonAttrs {
    preConfigure = ''
      substituteInPlace setup.py --replace \'setuptools-markdown\' ""
    '';
  };

  wheel =
    let
      isWheel = super.wheel.src.isWheel or false;
      # If "wheel" is a pre-built binary wheel
      wheelPackage = super.buildPythonPackage {
        inherit (super.wheel) pname name version src;
        inherit (pkgs.python3.pkgs.wheel) meta;
        format = "wheel";
      };
      # If "wheel" is built from source
      sourcePackage = (
        pkgs.python3.pkgs.override {
          python = self.python;
        }
      ).wheel.overridePythonAttrs (
        old: {
          inherit (super.wheel) pname name version src;
        }
      );
    in
    if isWheel then wheelPackage else sourcePackage;

  zipp = if super.zipp == null then null else
  (
    if lib.versionAtLeast super.zipp.version "2.0.0" then
      (
        super.zipp.overridePythonAttrs (
          old: {
            prePatch = ''
              substituteInPlace setup.py --replace \
              'setuptools.setup()' \
              'setuptools.setup(version="${super.zipp.version}")'
            '';
          }
        )
      ) else super.zipp
  ).overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self.toml
      ];
    }
  );

  credis = super.credis.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.cython ];
    }
  );

  hashids = super.hashids.overridePythonAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ self.flit-core ];
    }
  );

  supervisor = super.supervisor.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        self.meld3
        self.setuptools
      ];
    }
  );

  cytoolz = super.cytoolz.overridePythonAttrs (
    old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.toolz ];
    }
  );
}
