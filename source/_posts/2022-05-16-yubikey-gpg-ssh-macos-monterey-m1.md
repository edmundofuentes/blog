---
title: Configuring a YubiKey with GPG for SSH Authentication in macOS Monterey on a Mac Studio M1 Max
tags:
    - ssh
    - yubikey
    - security
    - macos
categories:
    - devops
---

_This is an update of my original guide for [macOS 10.3 High Sierra](blog/2018/06/27/yubikey-gpg-ssh/)_

This guide was tested on my current development setup:

- **Local:** macOS Monterey 12.13.1 on a Mac Studio M1 Max (Mac13,1)
- **Remote:** AWS EC2 Ubuntu 18.04 LTS (Server, Bionic Beaver)

And for the hardware, I'm using a couple of [YubiKey 5](https://www.yubico.com/products/yubikey-hardware/). I highly recommended that you get at least a pair of them. Throughout the guide and in the GnuPG references, the YubiKey is referred to as a _card_, while _key_ refers to a [RSA Key](https://en.wikipedia.org/wiki/RSA_(cryptosystem)).

Do note that macOS has changed a bit in the past releases, and it has introduced some variations between Intel and Apple Silicon installations.  For example, in Intel the default path for binaries is `/usr/local/bin`, while in Apple Silicon `/opt/homebrew/bin` is used. Also, this guide is written for zsh, as this shell has been shipping as the default in macOS for a while now.


## 1. Configure your Local Machine

We need to install some utilities in the local machine provide the basic functionality to interfase with the YubiKey. We'll be using [GnuPG](https://gnupg.org):

> GnuPG is a complete and free implementation of the OpenPGP standard as defined by [RFC4880](https://www.ietf.org/rfc/rfc4880.txt) (also known as PGP). GnuPG allows you to encrypt and sign your data and communications; it features a versatile key management system, along with access modules for all kinds of public key directories. GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications. A wealth of frontend applications and libraries are available. **GnuPG also provides support for S/MIME and Secure Shell (ssh)**.

The easiest way to install GnuPG in macOS is by using [Homebrew](https://brew.sh), and it might be a good idea to install the Rosetta 2 translation layer before installing anything else:

```bash
softwareupdate --install-rosetta
```

If your shell profile does not specify a language with `LANG`, then `gnupg2` will try to guess the best language for you. For some unknown reason, my installation decided that it'd be better in spanish and while the intention is appreciated, the command line utilities are a bit wonky in languages other than english.

However, this is a very quick fix. We'll set the appropiate `LANG` environment variable in the bash profile to `en`.

```bash
echo 'export LANG=en' >> ~/.zshrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
```

Finally, install the required packages for GnuPG (`gnupg2` now ships with its own built-in `gpg-agent`):

```bash
brew install gnupg2 pinentry-mac
```

We will need to adjust some permissions to the files and directories created by the installer.

```
mkdir -p ~/.gnupg
chown -R $(whoami) ~/.gnupg/
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

Along with GnuPG, we've installed a utility called `gpg-agent` which operates as a link between the YubiKey and the underlying GPG libraries. In order to improve the compatibility between macOS and the YubiKey, we need to add the following lines to the `gpg-agent` configuration file located in `~/.gnupg/gpg-agent.conf`

Create a new file and add the following lines with `nano ~/.gnupg/gpg-agent.conf`:

```
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 3600
default-cache-ttl-ssh 3600
max-cache-ttl 7200
max-cache-ttl-ssh 7200
enable-ssh-support
```

We also need to update the shell environment to allow `ssh` to use `gpg-agent` as an authentication service.
(Note: the single quote (`'`) and double quotes (`"`) behave differently in shell/bash)

```bash
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
echo 'export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh' >> ~/.zshrc
```

Close all your current terminal windows and restart the Terminal application.

Restart the `gpg-agent` service and update its settings:

```bash
gpg-connect-agent killagent /bye
gpg-connect-agent updatestartuptty /bye
gpg-connect-agent /bye
```

The 3 lines above are incredibly helpful becase `gpg` is a bit unstable in macOS and you might need to restart it from time to time. I recommend you register this alias:

```bash
echo "alias gpgreset='gpg-connect-agent killagent /bye; gpg-connect-agent updatestartuptty /bye; gpg-connect-agent /bye'" >> ~/.zshrc
```

This way, whenever you have any funkiness with your cards and your ssh sessions, you can simply write `gpgreset` and retry.  That will fix the issues most of the time.

Finally, insert your YubiKey in a USB port and check if it is being correctly detected by running the command:

```bash
gpg --card-status
```

You should see the details of your YubiKey (card) in the console. Take note of the Serial Number of the card, it might be of use later in the setup.

### Troubleshooting
If you cannot see the details of your card or you are getting other errors, first try a `gpgreset` and if that doesn't fix it, then carefully re-read this guide.

If you are getting this specific error:
```
gpg: selecting card failed: Operation not supported by device
gpg: OpenPGP card not available: Operation not supported by device
```

Try to add the following line to the file `~/.gnupg/scdaemon.conf`:
```
disable-ccid
```


## 2. YubiKey configuration

Please follow my [previous guide](blog/2018/06/27/yubikey-gpg-ssh/) (from section 2 onwards) to initialize your YubiKey in case it's new, and to generate its key pairs to be used with ssh.





