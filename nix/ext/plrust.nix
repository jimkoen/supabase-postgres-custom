{
   lib,
   stdenv,
   fetchFromGitHub,
   postgresql,
   buildPgrxExtension,
   cargo,
   rust-bin,
   cargo-binutils,
   buildPgrxExtension_0_11_3,
   rustc
    }:
let
  rustVersion = "1.72.0";
  cargo = rust-bin.stable.${rustVersion}.default;
in
buildPgrxExtension_0_11_3 rec {
  pname = "plrust";
  version = "1.2.7";
  inherit postgresql;

  strictDeps = false;

  src = fetchFromGitHub {
owner = "jimkoen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-RI0M6RpXG71CyrtC9Doi2yqIz3Szl+vQHtCuGczBF3o=";
  };
  cargoHash = "sha256-a19FMK7U9KuZXcuROQDHSVc9G0GiQZ1XCrREltonxGc=";
  useFetchCargoVendor = true;

 # nativeBuildInputs = [ cargo cargo-binutils rustc ];
 # buildInputs = [ postgresql ];
  # update the following array when the pg_jsonschema version is updated
  # required to ensure that extensions update scripts from previous versions are generated

#  previousVersions = [];
#  CARGO="${cargo}/bin/cargo";
#  env = lib.optionalAttrs stdenv.isDarwin {
#    POSTGRES_LIB = "${postgresql}/lib";
#    RUSTFLAGS = "-C link-arg=-undefined -C link-arg=dynamic_lookup";
#  };
#  cargoHash = "sha256-a19FMK7U9KuZXcuROQDHSVc9G0GiQZ1XCrREltonxGc=";

  # FIXME (aseipp): testsuite tries to write files into /nix/store; we'll have
  # to fix this a bit later.
  doCheck = false;

  preBuild = ''
   cat Cargo.lock
  '';

 # preBuild = ''
#
#    echo "Processing git tags..."
#    echo '${builtins.concatStringsSep "," previousVersions}' | sed 's/,/\n/g' > git_tags.txt
#    cd ./plrustc
#    ${stdenv.shell}
#    bash ./build.sh install
#    mv ../build/bin/plrustc ~/.cargo/bin/
#
#    cd ../plrust
#    PG_VER=15 \
#        STD_TARGETS="x86_64-postgres-linux-gnu " \
#        ./build install
#
#  '';

  postInstall = ''
    echo "Creating SQL files for previous versions..."
    current_version="${version}"
    sql_file="$out/share/postgresql/extension/pg_jsonschema--$current_version.sql"

    if [ -f "$sql_file" ]; then
      while read -r previous_version; do
        if [ "$(printf '%s\n' "$previous_version" "$current_version" | sort -V | head -n1)" = "$previous_version" ] && [ "$previous_version" != "$current_version" ]; then
          new_file="$out/share/postgresql/extension/pg_jsonschema--$previous_version--$current_version.sql"
          echo "Creating $new_file"
          cp "$sql_file" "$new_file"
        fi
      done < git_tags.txt
    else
      echo "Warning: $sql_file not found"
    fi
    rm git_tags.txt
  '';


  meta = with lib; {
    description = "PL/Rust trusted procedural language";
    homepage = "https://github.com/jimkoen/${pname}";
    platforms = postgresql.meta.platforms;
    license = licenses.postgresql;
  };
}
