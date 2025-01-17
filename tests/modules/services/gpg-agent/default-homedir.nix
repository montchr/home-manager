{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  socketPath = if isDarwin then
    config.launchd.agents.gpg-agent.config.Sockets.ssh.SockPathName
  else
    config.systemd.user.sockets.gpg-agent.Socket.ListenStream;

in {
  config = {
    services.gpg-agent.enable = true;
    services.gpg-agent.pinentryFlavor = null; # Don't build pinentry package.
    programs.gpg.enable = true;

    test.stubs.gnupg = { };
    test.stubs.systemd = { }; # depends on gnupg.override

    nmt.script = ''
      in="${socketPath}"
      if [[ $in != "%t/gnupg/S.gpg-agent" ]]
      then
        echo $in
        fail "gpg-agent socket directory not set to default value"
      fi
    '';
  };
}
