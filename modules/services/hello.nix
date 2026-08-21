let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.hello = mkService {
    name = "hello";
    description = "Simple HTTP hello service";
    extraOptions =
      { lib, ... }:
      {
        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Host interface address for the hello HTTP service to bind to.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Port for the hello HTTP service.";
        };
      };
    content =
      {
        cfg,
        pkgs,
        self,
        ...
      }:
      let
        helloPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.hello;
        helloServer = pkgs.writeShellApplication {
          name = "hello-server";
          runtimeInputs = [ pkgs.python3 ];
          text = ''
                        python3 -c '
            import http.server
            import subprocess
            import sys

            host = "${cfg.host}"
            port = ${toString cfg.port}

            class Handler(http.server.BaseHTTPRequestHandler):
                def do_GET(self):
                    try:
                        output = subprocess.check_output(["${helloPkg}/bin/hello"])
                    except Exception as e:
                        self.send_response(500)
                        self.end_headers()
                        self.wfile.write(str(e).encode("utf-8"))
                        return

                    self.send_response(200)
                    self.send_header("Content-Type", "text/plain; charset=utf-8")
                    self.send_header("Content-Length", str(len(output)))
                    self.end_headers()
                    self.wfile.write(output)

                def log_message(self, format, *args):
                    sys.stdout.write("%s - - [%s] %s\n" % (self.address_string(), self.log_date_time_string(), format % args))

            print(f"Starting HTTP hello service on {host}:{port}...")
            server = http.server.HTTPServer((host, port), Handler)
            server.serve_forever()
            '
          '';
        };
      in
      {
        environment.systemPackages = [ helloPkg ];

        systemd.services.hello = {
          description = "Hello HTTP Service";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            ExecStart = "${helloServer}/bin/hello-server";
            Restart = "always";
            DynamicUser = true;
          };
        };
      };
  };
}
