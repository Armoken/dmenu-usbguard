{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      dmenu-usbguard = pkgs.python3Packages.buildPythonApplication {
        pname = "dmenu-usbguard";
        version = "1.1";

        pyproject = true;
        build-system = [ pkgs.python3Packages.setuptools ];

        propagatedBuildInputs = with pkgs.python3Packages; [
          dbus-python # A zero-dependency DBus library for Python with asyncio support.
        ];

        src = ./.;
      };
      python-with-packages = ((pkgs.python3.withPackages(ps: [
        ps.ipython # IPython: Productive Interactive Computing.

        ps.dbus-python
      ])).overrideAttrs (args: { ignoreCollisions = true; doCheck = false; }));
    in {
      defaultPackage = dmenu-usbguard;
      devShell       = pkgs.mkShell {
        nativeBuildInputs = [
          python-with-packages

          pkgs.pyright                 # Type checker for the Python language.
          pkgs.fish
        ];
        shellHook = ''
        PYTHONPATH=${python-with-packages}/${python-with-packages.sitePackages}
        # maybe set more env-vars
        '';

        runScript = "fish";
      };
    }
  );
}
