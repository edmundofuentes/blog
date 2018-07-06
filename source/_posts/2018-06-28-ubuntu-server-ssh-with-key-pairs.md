---
title: Ubuntu Server SSH with Key Pairs
tags:
    - ssh
    - security
categories:
    - devops
---

## Authorized Keys

If it doesn't exist yet, create a `.ssh` folder inside your user's home directory.

```
cd ~
mkdir .ssh
```

Make sure the folder's permissions are correct by running `ls -la`.

Now, create (or append) a file called `authorized_keys` inside the `.ssh` folder.

```
touch ~/.ssh/authorized_keys
```

Copy the contents of your public key into the `authorized_keys` file. If you have imported the `.pub` file into your server, you can run a command such as

```
cat ~/.ssh/pubkey.pub >> ~/.ssh/authorized_keys
```

## SSH config

The file is in `/etc/ssh/sshd_config`

Before continuing, I recommend you first create a sshd_config backup

```
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```


Make all login tests and attempts from a new terminal window, and keep a SSH session open at all times.


Public Key Access
Uncomment and set yes to the option `PubkeyAuthentication`

```
PubkeyAuthentication yes
```

```
AuthorizedKeysFile .ssh/authorized_keys
```



Disable root account
```
PermitRootLogin no
```

What is PAM for??

```
UsePAM yes
```

Save the file and restart the SSH daemon service.

```
sudo systemctl restart ssh
```

Attempt to login now from a second terminal window using your IdentityFile or GPG card. If all went well, the server shouldn't have asked for your password and you should login directly.


If so, you can now safely disable password logins.

Disable password login
```
PasswordAuthentication no
PermitEmptyPasswords no
```

Restart again the SSH daemon:

```
sudo systemctl restart sshd_config
```

Try to login again without an IdentityFile and you should get an error such as:

```
Permission denied (publickey).
```

Sudoers

master file `/etc/sudoers`

```
myuser	ALL=(ALL:ALL) ALL
```


```
myuser	ALL=(ALL) NOPASSWD:ALL
```

Delete Your User PASSWORD

```
sudo passwd --delete myuser
```
