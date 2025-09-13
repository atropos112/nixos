{options, ...}: {
  networking = {
    timeServers =
      options.networking.timeServers.default
      ++ [
        "time-a-g.nist.gov"
        "utcnist3.colorado.edu"
        "0.europe.pool.ntp.org"
        "1.europe.pool.ntp.org"
        "2.europe.pool.ntp.org"
        "3.europe.pool.ntp.org"
      ];
  };
}
