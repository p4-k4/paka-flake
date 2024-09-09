{
  description = "Minimal Nix Flake for aarch64 Darwin with zsh, oh-my-zsh, Kitty, and Aerospace";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs, darwin, ... }:
    let
      userName = "paka";
      homePath = "/Users/${userName}";
      hostName = "pakas-Mac-mini";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.${hostName} = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          {
            networking.hostName = hostName;
            users.users.${userName} = { name = userName;
              home = homePath;
              shell = nixpkgs.legacyPackages.${system}.zsh;
            };
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            services.nix-daemon.enable = true;
            nix.useDaemon = true;
            environment.systemPackages = with nixpkgs.legacyPackages.${system}; [
              zsh
              curl
              neovim
              tree
              ripgrep
              fd
              git
              lazygit
              neofetch
              lolcat
              autojump
              gh
              htop
              # Editors
              vim
              neovim
              neovide
              # Languages and runtimes
              cargo
              rustc
              nodejs
              # Shells and shell utilities
              zsh
              zsh-autosuggestions
              zsh-syntax-highlighting
            ];
            environment.shells = with nixpkgs.legacyPackages.${system}; [ zsh ];

            programs.zsh = {
              enable = true;
              enableCompletion = true;
              enableBashCompletion = true;
              promptInit = "";
            };

            # Homebrew configuration
            homebrew = {
              enable = true;
              onActivation = {
                autoUpdate = true;
                cleanup = "zap";
              };
              taps = [
                "nikitabobko/tap"
              ];
              casks = [
                "kitty"
                "aerospace"
              ];
            };

            system.activationScripts.postActivation.text = ''
              # Ensure the setup script has execute permissions
              chmod +x ${./scripts/setup-system-config.sh}

              # Run the setup script with absolute paths
              ${./scripts/setup-system-config.sh} "${userName}" "${homePath}" "${./scripts}" "${./config}"
            '';

            system.stateVersion = 4;
          }
        ];
      };
    };
}
