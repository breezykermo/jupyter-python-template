{
  description = "Tyler course - Python development environment with JupyterLab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, uv2nix, pyproject-nix, pyproject-build-systems }:
    let
      inherit (nixpkgs) lib;

      # Support multiple systems
      forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Read python version from .python-version
          pythonVersion = lib.strings.trim (builtins.readFile ./.python-version);
          python = pkgs."python${lib.strings.replaceStrings ["."] [""] pythonVersion}";

          # Load the uv workspace
          workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

          # Create package overlay from workspace
          overlay = workspace.mkPyprojectOverlay {
            sourcePreference = "wheel"; # Prefer wheels for faster builds
          };

          # Construct Python package set
          pythonSet =
            (pkgs.callPackage pyproject-nix.build.packages {
              inherit python;
            }).overrideScope (
              lib.composeManyExtensions [
                pyproject-build-systems.overlays.default
                overlay
              ]
            );

          # Build virtual environment
          virtualenv = pythonSet.mkVirtualEnv "tyler-course-env" workspace.deps.default;

        in
        {
          default = pkgs.mkShell {
            packages = [
              virtualenv
              pkgs.uv
              pkgs.just
            ];

            shellHook = ''
              # Unset PYTHONPATH to avoid conflicts
              unset PYTHONPATH

              echo "🚀 Development Environment"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "Python: ${python.version}"
              echo "JupyterLab: Available in virtual environment"
              echo ""
              echo "Commands:"
              echo "  just dev       - Start JupyterLab"
              echo "  uv add <pkg>   - Add a Python package"
              echo "  uv remove <pkg> - Remove a Python package"
              echo ""
            '';
          };
        }
      );
    };
}
