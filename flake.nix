{
  description = "Python Template";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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

        python = pkgs.python313;
        pythonPackages = pkgs.python313Packages;

        nativeBuildInputs = with pkgs; [
          makeWrapper
          python
        ];

        propagatedBuildInputs = with pkgs; [
          pythonPackages.tomlkit
          pythonPackages.click-aliases
          pythonPackages.click
        ];

        runtimeDeps = with pkgs; [
          kmod       # for lsmod/modprobe
          coreutils  # for common shell tools
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
              --set PYTHONPATH "${pythonPackages.tomlkit}/${python.sitePackages}:${pythonPackages.click-aliases}/${python.sitePackages}:${python.sitePackages}" \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
            wrapProgram $out/bin/omen-fand \
              --set PYTHONPATH "${pythonPackages.tomlkit}/${python.sitePackages}:${pythonPackages.click-aliases}/${python.sitePackages}:${python.sitePackages}" \
              --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
          '';

          meta = with pkgs.lib; {
            description = "A Python application with tomlkit and click-aliases";
            license = licenses.mit;
            maintainers = with maintainers; [ cician ];
          };

          inherit nativeBuildInputs propagatedBuildInputs runtimeDeps;
        };
      }
    );
}
