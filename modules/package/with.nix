{
  perSystem =
    { pkgs, ... }:
    {
      packages."with" = pkgs.writeShellApplication {
        name = "with";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          #!/usr/bin/env bash
          if (( $# == 0 )); then
            printf >&2 'Usage: %s <package-name> [nix‑shell args…]\n' "$0"
            exit 1
          fi

          # Grab the first argument (the package name) and shift it off
          PACKAGE="$1"
          shift

          # Build the nix‑shell command
          CMD=(nix shell)

          # If the NH_FLAKE variable is set, add the inputs‑from flag
          if [[ -n "''${NH_FLAKE:-}" ]]; then
            CMD+=("--inputs-from" "$NH_FLAKE")
          fi

          # Target expression
          CMD+=("nixpkgs#''${PACKAGE}")

          # Forward any remaining user‑supplied arguments
          CMD+=("$@")

          # Replace the wrapper with the actual nix shell
          exec "''${CMD[@]}"
        '';
      };
    };
}
