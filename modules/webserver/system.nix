{ pkgs, ... }:
let
  # A plain, dependency-free services directory -- no external fonts/CDNs,
  # so it still renders if the LAN's internet uplink is down. Built as a Nix
  # store path so the page is always exactly what's in this file; nothing on
  # erebor edits it by hand.
  servicesPage = pkgs.writeTextDir "index.html" ''
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>erebor</title>
      <style>
        :root {
          --bg: #1d2021; --fg: #ebdbb2; --fg-muted: #a89984;
          --card: #282828; --border: #504945; --accent: #fb4934;
        }
        * { box-sizing: border-box; }
        body {
          margin: 0; min-height: 100vh;
          background: var(--bg); color: var(--fg);
          font: 16px/1.5 -apple-system, "Segoe UI", Roboto, sans-serif;
          padding: 40px 16px;
        }
        main { max-width: 520px; margin: 0 auto; }
        h1 {
          font-family: ui-monospace, "SF Mono", Consolas, monospace;
          color: var(--accent); margin: 0 0 4px; font-size: 28px;
        }
        p.sub { color: var(--fg-muted); margin: 0 0 28px; font-size: 14px; }
        ul { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 10px; }
        li {
          background: var(--card); border: 1px solid var(--border);
          border-radius: 10px; padding: 14px 16px;
        }
        a { color: var(--fg); text-decoration: none; font-weight: 600; font-size: 16px; }
        a:hover { color: var(--accent); }
        .desc { color: var(--fg-muted); font-size: 13.5px; margin-top: 3px; }
        .other {
          margin-top: 28px; padding-top: 18px; border-top: 1px solid var(--border);
          color: var(--fg-muted); font-size: 13.5px; line-height: 1.8;
        }
        .other code {
          font-family: ui-monospace, monospace; color: var(--fg);
          background: var(--card); border: 1px solid var(--border);
          border-radius: 4px; padding: 1px 5px;
        }
      </style>
    </head>
    <body>
      <main>
        <h1>erebor</h1>
        <p class="sub">home server</p>
        <ul>
          <li>
            <a href="http://erebor.local:8080">FileBrowser</a>
            <div class="desc">upload / browse files</div>
          </li>
          <li>
            <a href="http://erebor.local:8096">Jellyfin</a>
            <div class="desc">movies, TV, music</div>
          </li>
          <li>
            <a href="http://erebor.local:8081">ARM</a>
            <div class="desc">disc ripper</div>
          </li>
        </ul>
        <div class="other">
          Samba: <code>smb://erebor.local/storage</code><br>
          NFS: <code>erebor.local:/mnt/storage</code>
        </div>
      </main>
    </body>
    </html>
  '';
in
{
  # Port-only virtualHost keys (":80") instead of a domain name, so Caddy
  # doesn't try to provision a Let's Encrypt cert for a host that's only
  # reachable over the LAN/tailnet. Point a real domain at erebor and switch
  # this to a domain-name key later if a site needs public HTTPS.
  services.caddy = {
    enable = true;
    virtualHosts.":80".extraConfig = ''
      root * ${servicesPage}
      file_server
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
