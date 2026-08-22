let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  secret = mkSecret {
    name = "github-mcp-pat";
    moduleName = "antigravity";
    owner = "vorburger";
    mode = "0400";
  };
in
{ lib, ... }:
lib.recursiveUpdate secret {
  flake-file.inputs.antigravity.url = "github:Hy4ri/antigravity-flake";
  flake-file.inputs.antigravity.inputs.nixpkgs.follows = "nixpkgs";

  flake.nixosModules.antigravity =
    _:
    lib.recursiveUpdate secret.flake.nixosModules.antigravity {
      home-manager.users.vorburger =
        { lib, pkgs, ... }:
        {
          home.activation.antigravity-mcp-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ -f /run/secrets/github-mcp-pat ]; then
              PAT=$(${pkgs.coreutils}/bin/cat /run/secrets/github-mcp-pat | ${pkgs.coreutils}/bin/tr -d '\n\r ')
              ${pkgs.coreutils}/bin/mkdir -p "$HOME/.gemini/config" "$HOME/.gemini/antigravity" "$HOME/.gemini/antigravity-ide"
              ${pkgs.jq}/bin/jq -n \
                --arg pat "$PAT" \
                '{
                  mcpServers: {
                    nix: {
                      command: "nix",
                      args: ["run", "github:utensils/mcp-nixos", "--"]
                    },
                    context7: {
                      serverUrl: "https://mcp.context7.com/mcp",
                      headers: {
                        Accept: "application/json, text/event-stream"
                      }
                    },
                    # Note: We cannot use remote "https://api.githubcopilot.com/mcp/" because GitHub
                    # does not support OAuth Dynamic Client Registration (RFC 7591) and drops raw-PAT
                    # SSE stream subscriptions with "session not found". Running github-mcp-server
                    # locally via stdio with GITHUB_PERSONAL_ACCESS_TOKEN works reliably across all hosts.
                    github: {
                      command: "${pkgs.github-mcp-server}/bin/github-mcp-server",
                      args: ["stdio"],
                      env: {
                        GITHUB_PERSONAL_ACCESS_TOKEN: $pat
                      }
                    }
                  }
                }' > "$HOME/.gemini/config/mcp_config.json.tmp"
              ${pkgs.coreutils}/bin/chmod 600 "$HOME/.gemini/config/mcp_config.json.tmp"
              ${pkgs.coreutils}/bin/mv "$HOME/.gemini/config/mcp_config.json.tmp" "$HOME/.gemini/config/mcp_config.json"
              ${pkgs.coreutils}/bin/ln -sfn "$HOME/.gemini/config/mcp_config.json" "$HOME/.gemini/antigravity/mcp_config.json"
              ${pkgs.coreutils}/bin/ln -sfn "$HOME/.gemini/config/mcp_config.json" "$HOME/.gemini/antigravity-ide/mcp_config.json"
            fi
          '';
        };
    };
}
