---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - ntp
    - ubuntu
categories:
    - devops
---

Before Ubuntu 16.04, most network time sync was handled with the _Network Time Protocol_ (NTP) and its _daemon_ (`ntpd`). Using NTP, the local machine connects to a pool of NTP servers that provide it with constant and accurate time updates. However, since Ubuntu 16.04 the default time synchronization deamon being used is `timesyncd`, and ships enabled by default on all new Ubuntu installations.


You can easily check it by running the `timedatectl` command:

```bash 
$ timedatectl
                      Local time: Mon 2018-11-19 17:17:21 UTC
                  Universal time: Mon 2018-11-19 17:17:21 UTC
                        RTC time: Mon 2018-11-19 17:17:22
                       Time zone: Etc/UTC (UTC, +0000)
       System clock synchronized: yes
systemd-timesyncd.service active: yes
                 RTC in local TZ: no
```

Take a note at the line `systemd-timesyncd.service active: yes`, which means that the time synchronization deamon being used is `timesyncd`, which is the [default on Ubuntu installations ship with since 16.04](https://help.ubuntu.com/lts/serverguide/NTP.html.en): 

> Since Ubuntu 16.04 `timedatectl` / `timesyncd` (which are part of systemd) replace most of `ntpdate` / `ntp`.
> 
> `timesyncd` is available by default and replaces not only `ntpdate`, but also the client portion of `chrony` (or formerly `ntpd`). So on top of the one-shot action that `ntpdate` provided on boot and network activation, now `timesyncd` by default regularly checks and keeps your local time in sync. It also stores time updates locally, so that after reboots monotonically advances if applicable.

`timesyncd` should be fine for most purposes, but for some high-precision applications `NTP` is still the way to go.

## Enabling `ntpd` 

Before installing and enabling `ntpd` (the client or _deamon_ process), we have to disable the default `timesyncd`

```bash
$ sudo timedatectl set-ntp no
$ timedatectl
                      Local time: Mon 2018-11-19 17:35:21 UTC
                  Universal time: Mon 2018-11-19 17:35:21 UTC
                        RTC time: Mon 2018-11-19 17:35:22
                       Time zone: Etc/UTC (UTC, +0000)
       System clock synchronized: yes
systemd-timesyncd.service active: no
                 RTC in local TZ: no
```

We check that the `systemd-timesyncd-service` is disabled, and then we proceed to install `ntp` via `apt-get`.

```bash
$ sudo apt-get install -y ntp
```

The NTP daemon should have been started by default after the restart. To verify that it was correctly installed and working we can use the query tool for NTP `ntpq`, using the `-p` flag to print information about it's peers (NTP servers).

```bash
$ sudo ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 1.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 2.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 3.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 ntp.ubuntu.com  .POOL.          16 p    -   64    0    0.000    0.000   0.000
-ntp6.flashdance 192.36.143.152   2 u   38   64    1  159.692   10.730   2.336
+ntp7.flashdance 194.58.202.148   2 u   39   64    1  164.543    9.626   2.791
*time100.stupi.s .PPS.            1 u   39   64    1  155.059    6.076   2.629
+ntp8.flashdance 192.36.143.151   2 u   41   64    1  164.777    6.715   1.999
-ntp2.flashdance 194.58.202.148   2 u   38   64    1  153.563    5.630   3.300
-ntp5.flashdance 192.36.143.151   2 u   41   64    1  149.059    6.564   2.724
 chilipepper.can 17.253.34.253    2 u   48   64    1  131.168    0.113   0.000
 golem.canonical 145.238.203.14   2 u   51   64    1  129.830    0.024   0.000
 pugot.canonical 193.79.237.14    2 u   51   64    1  129.574    0.071   0.000
 alphyn.canonica 17.253.52.125    2 u   50   64    1   67.961   -0.367   0.000
```

Run `timedatectl` one last time to check that the clock is synced.

```bash
$ timedatectl
                      Local time: Mon 2018-11-19 18:13:22 UTC
                  Universal time: Mon 2018-11-19 18:13:22 UTC
                        RTC time: Mon 2018-11-19 18:13:22
                       Time zone: Etc/UTC (UTC, +0000)
       System clock synchronized: yes
systemd-timesyncd.service active: no
                 RTC in local TZ: no
```

Even though the `timesyncd` service is off, the `System clock synchronized` flag should be `yes` because we are using `ntpd` on the background.
                

## Manually Forcing a Sync
If the system's clock is desynchronized by more than ~3 seconds, then `ntpd` might not be able to automatically sync the clock. In this case, we have to manually force the first sync.  To do this, we have to stop the `ntp` service to release the UDP port 123, then we run the forced sync, and after that's done we turn the `ntp` back on.

```bash 
$ sudo service ntp stop
$ sudo ntpd -gq
$ sudo service ntp start
```

We run the command `ntpd -gq`, the `-gq` flags tell the NTP daemon to adjust the time irrespective of the skew (g) and exit (q) immediately.


### References
- Brian Boucheron (DigitalOcean): ["How To Set Up Time Synchronization on Ubuntu 16.04"](https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-16-04)
- Jamie Arthur (LinOxide): ["How to Synchronize Time using NTP Server in Ubuntu"](https://linoxide.com/linux-how-to/synchronize-time-ntp-server-ubuntu/)
- Lubos Rendek (LinuxConfig.org): ["NTP Server configuration on Ubuntu 18.04 Bionic Beaver Linux"](https://linuxconfig.org/ntp-server-configuration-on-ubuntu-18-04-bionic-beaver-linux)