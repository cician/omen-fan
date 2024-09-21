{
  description = "Python Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python310;

        nativeBuildInputs = with pkgs; [
          python310
        ];

        propagatedBuildInputs = with pkgs; [
          python310Packages.tomlkit
          python310Packages.click-aliases
          python310Packages.click
        ];

      in {
        devShells.default = pkgs.mkShell {inherit nativeBuildInputs propagatedBuildInputs;};

        #packages.default = python.pkgs.buildPythonApplication {
        packages.default = python.pkgs.buildPythonPackage {
          pname = "template";
          version = "0.0.0";
          #format = "setuptools";
          format = "other";

          src = ./.;

          # True if tests
          doCheck = false;

          buildPhase = ''
            mkdir -p $out/bin
            cp ./omen-fan.py $out/bin/omen-fan
            cp ./omen-fand.py $out/bin/omen-fand
            chmod +x $out/bin/omen-fan
            chmod +x $out/bin/omen-fand
          '';

          installPhase = ''
            wrapProgram $out/bin/omen-fan \
              --set PYTHONPATH "${pkgs.python310Packages.tomlkit}/${python.sitePackages}:${pkgs.python310Packages.click-aliases}/${python.sitePackages}:${pkgs.python310.sitePackages}"
            wrapProgram $out/bin/omen-fand \
              --set PYTHONPATH "${pkgs.python310Packages.tomlkit}/${python.sitePackages}:${pkgs.python310Packages.click-aliases}/${python.sitePackages}:${pkgs.python310.sitePackages}"
          '';

          meta = with pkgs.lib; {
            description = "A Python application with tomlkit and click-aliases";
            license = licenses.mit;
            maintainers = with maintainers; [ cician ];
          };

          inherit nativeBuildInputs propagatedBuildInputs;
        };
      }
    );
}
