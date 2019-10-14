---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - ssh
    - security
    - ubuntu
categories:
    - devops
draft: yes
---


for the exercise, we'll use the username `bastion`.

Create a new user

```bash
sudo adduser --home /home/bastion bastion
```


If you need to allow this user to connect with a YubiKey or any other type of SSH Key Pair, read my other guide: https://www.edmundofuentes.com/blog/2018/06/28/ubuntu-server-ssh-with-key-pairs/

```bash
sudo passwd --delete bastion
```

Disable the regular shell for the user

Change the `bastion` user default shell to a "Restricted Bash"
```bash
sudo chsh -s /bin/rbash bastion
```

Change the `bastion` user default shell to a invalid shell (no shell at all)
```bash
sudo chsh -s /bin/false bastion
```

Limit the capabilities of the user's SSH session. Add at the bottom of the `sshd_config` file:

replace the argument `host:port` with your 

```apacheconfig
Match User bastion
	#AllowTcpForwarding yes
	#X11Forwarding no
	#PermitTunnel no
	#GatewayPorts no
	#AllowAgentForwading no
	PermitOpen host:port
	ForceCommand echo "This account can only be used as a Bastion host"
```


The important option is `PermitOpen`, from the manual:

> **permitopen="host:port"**
>
> Limits local `ssh -L` port forwarding such that it can only connect to the specified host and port. IPv6 addresses can be specified with an alternate syntax: host/port. Use commas to separate multiple permitopen options. No pattern matching is performed on the specified host names, they must be literal domains or addresses. A port specification of "*" matches any port.

Double check those changes to the `sshd_config` file and restart the ssh server.

```bash
sudo systemctl restart ssh
```

Make sure that the service restarts without any error or warning.  

As usual when making changes to a host's ssh server, attempt to reconnect to the box without closing the current session. That is, open a new connection from _another_ terminal to test if the setup is working as expected.

References:

https://askubuntu.com/a/50000


