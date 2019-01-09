---
title: Increasing Linux UDP RX Buffers
tags:
    - networking
    - linux
categories:
    - devops
draft: yes
---



> There’s a joke about UDP. it goes like this: “Never mind, you probably wouldn’t get it.”

Buffers everywhere.

Between the ___ 

the network card (network interface, NIC),
the router, the kernel, the application.

real-time feed -__ which sometimes bursts to a big amount of data happening in the same second.

My link is very stable, my switches and other network devices __ perfectly.

But still, at some points during the day I was losing __ 
after much reading __

I concluded that the problem laid with a buffer.


Application level

I'm processing each datagram as it arrives, parsing the bytes very quickly and finally sending it to a queue, then it'd read the
 and reading the next one. and so on.
 
There is not much to be said,
Read from the incoming connection as fast as possible, __ stash the data in a queue an process it later.

Tested it and still, 
while the __ number __ slightly decreased, the problem was nowhere near fixed.




NIC: Network Interface C..

Note: it is safe to assume that any change will briefly take the interface down and then up again, which could interrupt
any existing connection through the interface.  However, this behaviour depends on your particular interface and drivers.

We'll be using the amazing `ethtool` utility that provides a generic way to interact with the NIC and its drivers.

We'll be asumming an interface named `eth0`, but remember to replace it with your own.

## Interface level (NIC)

### Number of Queues
In case the NIC supports _multiqueue_

depends on your number of processors, threads, ... 
```bash
ethtool -l eth0
```

```bash
$> ethtool -l eth0
Channel parameters for eth0:
Pre-set maximums:
RX:		0
TX:		0
Other:		1
Combined:	128
Current hardware settings:
RX:		0
TX:		0
Other:		1
Combined:	16
```

In my particular case, my application was processing a huge single-thread feed, and__ I concluded I'd rather not modify this.

Still, if you'd want to configure the settings of
Set the number of queues
```bash
ethtool -L eth0 combined 8
```

some interfaces and drivers allow individual settings for TX and RX, which you could set like so:

```bash
ethtool -L eth0 rx 8
```

Kernel level
OS Socket receive buffer

```
$> sudo sysctl -a | grep mem
net.core.optmem_max = 20480
net.core.rmem_default = 212992
net.core.rmem_max = 212992
net.core.wmem_default = 212992
net.core.wmem_max = 212992
net.ipv4.igmp_max_memberships = 20
sysctl: net.ipv4.tcp_mem = 378249    504335    756498
net.ipv4.tcp_rmem = 4096    87380    6291456
net.ipv4.tcp_wmem = 4096    16384    4194304
net.ipv4.udp_mem = 756501    1008670    1513002
net.ipv4.udp_rmem_min = 4096
net.ipv4.udp_wmem_min = 4096
vm.lowmem_reserve_ratio = 256    256    32    1
vm.memory_failure_early_kill = 0
vm.memory_failure_recovery = 1
vm.nr_hugepages_mempolicy = 0
vm.overcommit_memory = 0
```

Those were my system's default settings, we'll pay special attention to the following two:

```bash
[...]
net.core.rmem_default = 212992
net.core.rmem_max = 212992
[...]
```

This means that my 208.0 KB

It is recommended by ____ to at least assign 25 MB of RX memory whenever __ you are doing somethign .. 

In my case, I opted to increase the kernel's net read memory to 32 MB (33554432 bytes)

This can be done with the same `sysctl` utility in Ubuntu like:


```bash 
$> sudo sysctl -w net.core.rmem_max=33554432
net.core.rmem_max = 33554432
$> sudo sysctl -w net.core.rmem_default=33554432
net.core.rmem_default = 33554432
```

To persist these changes after reboot, add them at the bottom of `/etc/sysctl.conf`

```
net.core.rmem_max=33554432
net.core.rmem_default=33554432
```

And that's it

After the kernel changes I went ahead and tested, no more problems at all.




# References
- Kaven Gagnon, "" http://www.itechlounge.net/2015/05/linux-how-to-tune-up-receive-tx-and-transmit-rx-buffers-on-network-interface/
https://jvns.ca/blog/2016/08/24/find-out-where-youre-dropping-packets/
https://blog.packagecloud.io/eng/2016/06/22/monitoring-tuning-linux-networking-stack-receiving-data/