Project Bedrock
===============

Opinionated, shared Nix module base, based on [flake-parts](https://flake.parts).

---

## Usage
Create a `flake.nix` (preferably in `/home/<username>/Flake/`) which pulls inputs from Bedrock:

```nix
{
    inputs = {
        bedrock.url = "github:emil1003/Bedrock";

        # Let Bedrock dictate your nixpkgs revision...
        nixpkgs.follows = "bedrock/nixpkgs";

        # ...or override it to choose your own
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        bedrock.inputs.nixpkgs.follows = "nixpkgs";

        # Pull dependencies from Bedrock
        home-manager.follows = "bedrock/home-manager";
    };

    outputs = inputs: {
        # Normal flake outputs here
    };
}
```

Nix modules can then reuse Bedrock modules from `inputs.bedrock.nixosModules`, `inputs.bedrock.homeModules`, etc.

