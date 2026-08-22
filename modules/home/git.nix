{ config, lib, pkgs, ... }:

let
  cfg = config.local.git;
in
{
  options.local.git = {
    enableGithubCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install the GitHub CLI (gh) and wire it up as git's credential helper
        for github.com/gist.github.com, so `gh auth login` credentials are
        picked up by plain git operations. Disable on hosts that don't need gh
        (e.g. minimal servers).
      '';
    };

    enableForgejoCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install the Forgejo CLI (fj). Unlike gh, fj has no git
        credential-helper integration, so it doesn't wire into plain git
        operations -- authenticate with `fj auth login` and use SSH remotes
        (`fj auth use-ssh true`) for git push/pull. Disable on hosts that
        don't need it (e.g. minimal servers).
      '';
    };
  };

  config = {
    programs.git = {
      enable = true;
      settings.user.name = "Lachlan Malec";
      settings.user.email = "lachlan@lachlanmalec.dev";
    };

    # gh's `gitCredentialHelper` (on by default) declares
    # programs.git.settings.credential.<host>.helper to point at this gh
    # package's store path, so `git push`/`git clone` etc. transparently use
    # whatever `gh auth login` has authenticated. gh's own token storage
    # (~/.config/gh/hosts.yml) is left unmanaged/mutable so `gh auth login`
    # can still write to it.
    programs.gh.enable = cfg.enableGithubCli;

    home.packages = lib.optional cfg.enableForgejoCli pkgs.forgejo-cli;
  };
}
