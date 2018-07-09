---
title: Enabling SSH Key Pair Authentication in Ubuntu Server 18.04
tags:
    - ssh
    - security
    - ubuntu
categories:
    - devops
---


### About SSH Keys

Here's a nice intro about SSH Keys written by DigitalOcean on their How-To guides: [How to Setup SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2) and [How to Configure SSH Key based authentication on a Linux Server](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server):

> Secure Shell (better known as SSH) is a cryptographic network protocol which allows users to securely perform a number of network services over an unsecured network. SSH keys provide a more secure way of logging into a server with SSH than using a password alone. While a password can eventually be cracked with a brute force attack, SSH keys are nearly impossible to decipher by brute force alone.

> Generating a key pair provides you with two long string of characters: a public and a private key. You can place the public key on any server, and then unlock it by connecting to it with a client that already has the private key. When the two match up, the system unlocks without the need for a password. You can increase security even more by protecting the private key with a passphrase.


### Requirements
This guide is was written and tested on a fresh installation of Ubuntu Server 18.04 LTS (Bionic Beaver), but the process and configuration should be the same for any modern Linux Distro.

We will also assume that (1) SSH is already enabled and working using a user and password combination, (2) you have access to the server and (3) you have superuser/admin rights.

## 1. Generate a RSA Key Pair

First, you need to generate a RSA Key Pair:

- Less secure: [Create a Key Pair on your local machine](https://www.howtoforge.com/linux-basics-how-to-install-ssh-keys-on-the-shell#step-onecreation-of-the-rsa-key-pair).
- More secure: use a Hardware Key / GPG Card such as a [YubiKey](https://www.yubico.com/products/yubikey-hardware/). ([Read my guide about YubiKey GPG configuration](https://www.edmundofuentes.com/blog/2018/06/27/yubikey-gpg-ssh/))

You should end up with a Public Key file, we'll call it `mykey.pub` throughout this guide.

## 2. Set up the Authorized Keys file

Look for a directory in your server user's home directory called `.ssh`. Note that the period before the name means that it is a hidden directory, so you have to use `ls -a` in order to display all files, including the hidden ones.

If the `.ssh` directory doesn't exist yet, we'll create it:

```bash
cd ~
mkdir .ssh
chown myuser:myuser -R .ssh
```

Make sure the directory's permissions are correct by running `ls -la`.

### Copy your Public Key to the server

You can use any method you prefer to copy your public key file to the server. I like to use `scp`:

```bash
scp  ~/.ssh/mykey.pub <user>@<host>:~/.ssh/mykey.pub
```


### Add your Public Key to the Authorized Keys list

We'll now create a file called `authorized_keys` inside the `.ssh` directory, and we'll copy the contents of your public key into this file. If the file already exists this command will only append your public key to the file but it won't delete any previous records.

```bash
touch ~/.ssh/authorized_keys
cat ~/.ssh/mykey.pub >> ~/.ssh/authorized_keys
```

## 3. Configure SSH to use Authorized Keys

The main configuration file for the SSH server is in `/etc/ssh/sshd_config`. Before continuing, I recommend you first create a backup of the configuration file.

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

Edit the file using `nano` (or `vim`):

```bash
sudo nano /etc/ssh/sshd_config
```

Make the following changes to the configuration file. All of these options should already be in the file,  you might have to uncomment (remove the `#` at the start of the line) or change the default value.

#### Public Key Authentication

```apacheconfig
PubkeyAuthentication yes
```

```apacheconfig
AuthorizedKeysFile .ssh/authorized_keys
```


#### Disable root account
```apacheconfig
PermitRootLogin no
```

#### Enable PAM
We have to make sure that PAM (_Pluggable Authentication Modules_) is enabled in our config, since it provides the base API to enable Key Authentication. [Here's a nice explanation about PAM](https://www.ibm.com/developerworks/aix/library/au-sshlocks/index.html#allow_users).

```apacheconfig
UsePAM yes
```


Save the config file and restart the SSH daemon service.

```bash
sudo systemctl restart ssh
```

Without closing your current terminal/session, attempt to login now from a second terminal window using your IdentityFile (.pem) or GPG card. If all went well, the server should not have asked for your password and instead should have logged you in directly.


## 4. Disable Password Authentication

If you were able to login using your Private Key, you can now safely disable password logins. We'll edit the SSH Config file again:

```bash
sudo nano /etc/ssh/sshd_config
```

#### Disable password login
```apacheconfig
PasswordAuthentication no
PermitEmptyPasswords no
```

Restart once again the SSH daemon:

```bash
sudo systemctl restart sshd_config
```

Try to login with your Private Key, it should still work.


Try to login again without an IdentityFile and instead of the server asking you for a password, you should get an error such as:

```
Permission denied (publickey).
```

Nice.

## 5. Delete your User Password
Now there's no point in keeping a user password in your server, you won't be able to use it to login and it'll only nag you when you try to run SuperUser (`sudo`) commands. Or worse, you might forget it.

First we make sure that our user does not need to input a password when running `sudo`, so we'll modify the `sudoers` file located in `/etc/sudoers`.

```bash
sudo nano /etc/sudoers
```

Look for a line containing your username such as:

```
myuser	ALL=(ALL:ALL) ALL
```

If it exists, modify it as follows, if not, simply create the line.

```
myuser	ALL=(ALL) NOPASSWD:ALL
```

Make sure that your user definition is placed _after_ any other user or group definition that includes your user.  For example, it should go _after_ the `%sudo` group definition.

According to the `sudo` man page:

>   When multiple entries match for a user, they are applied in order. Where there are multiple matches, the last match is used (which is not necessarily the most specific match).

Test your new `sudo` powers, it shouldn't have asked you for your password.

Finally, you can safely delete your user password. Replace `myuser` with your current user in the command:

```
sudo passwd --delete myuser
```

That's it.


## References
- HowtoForge, ["How To Create and Install SSH Keys on the Shell](https://www.howtoforge.com/linux-basics-how-to-install-ssh-keys-on-the-shell#step-onecreation-of-the-rsa-key-pair)
- Feredico Kereki, IBM developerWorks, ["Three locks for your SSH door"](https://www.ibm.com/developerworks/aix/library/au-sshlocks/index.html#allow_users)
- DigitalOcean, ["How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)
- Justin Ellingwood, DigitalOcean, ["How To Configure SSH Key-Based Authentication on a Linux Server"](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)