{pkgs, ...}: {
   # service discovery on a local network via the mDNS/DNS-SD protocol
  services.avahi = {
      enable = true;
      # allows applications to resolve names in the .local domain by transparently querying the Avahi daemon.
      nssmdns4 = true;
      # open the firewall for UDP port 5353. discovering of network devices.
      openFirewall = true;
    };

}
