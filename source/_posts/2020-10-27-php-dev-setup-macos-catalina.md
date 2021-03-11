---
title: PHP Development setup in macOS Catalina
tags:
    - development
    - php
    - macos
categories:
    - development
draft: yes
---

The "old ways" would be to install MAMP, but that is outdated and not very flexible.

Instead, we're using ___

As a bare minimum,

We're installing the following packages:

- Homebrew:
- PHP
- MySQL
- GPG for YubiKey SSH support

The rest of the __ are __ 

This is written for macOS Catalina 10.15.7.

# Homebrew
Brew is the __ package manager __ for macOS. It's great, works very well..

Go to brew.sh 

Run a single line in your terminal and that's it.

Note: Brew might require you to have Xcode installed beforehand, you can get it (a) as a free download in the App Store, or (b) by downloading directly from the Apple Developer's website in case you have a dev account, this being the faster option of the two.


# PHP



Catalina comes bundled with PHP 7.3 by default, which is actually not bad, but it's compiled _ without some important and useful extensions (features), such as `ext-zip`. Since we'd rather not mess with macOS and its default packaging, 

Instead of adding,, we'll simply install the version we want with Brew, and let it handle the linkage.

that is, we can have _both_ versions of PHP installed, and through Brew we can select which one responds when you type `php` in the console.


```
brew update
brew install php@7.2
brew link php@7.2 --force
```


https://stackoverflow.com/a/58300437


The Brew Formula includes all commonly used 


To verify that PHP has been installed and the correct version has been linked correctly, simply type `php -v` in your terminal and you should see the correct version displayed.

```
$> php -v
PHP 7.2.33 (cli) (built: Aug  7 2020 18:29:34) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.33, Copyright (c) 1999-2018, by Zend Technologies
```

If you want to be completely sure that everything is linked as expected, you could also check _what_ binary is being executed when running `php`.

```
$> ls -la $(which php)
lrwxr-xr-x  1 mundofr  admin  32 Oct 26 10:01 /usr/local/bin/php -> ../Cellar/php@7.2/7.2.33/bin/php
```

Nifty.




# MySQL

Install MySQL

```
brew tap homebrew/services
brew install mysql@5.7
brew link mysql@5.7 --force
brew services start mysql@5.7
```

Update ___ your local password.. 

```
mysqladmin -u root password 'yourpassword'
```


Increase compatibility

SELECT @@GLOBAL.sql_mode global

```
nano /usr/local/etc/my.cnf
```


sql_mode=STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION


brew services restart mysql@5.7

_This is an update of my previous guide for [macOS 10.3 High Sierra](blog/2018/06/27/yubikey-gpg-ssh/)_

This guide was tested on my current development setup:

- **Local:** macOS 10.15.4 Catalina on a Mac Mini (2018 _8,1_)
- **Remote:** AWS EC2 Ubuntu 18.04 LTS (Server, Bionic Beaver)

And for the hardware, I'm using a couple of [YubiKey 4](https://www.yubico.com/products/yubikey-hardware/). I highly recommended that you get at least a pair of them.


TODO: replace .bash_profile with .zshrc, make a note about the shells 


Note: throughout the guide and in the GnuPG references, the YubiKey is referred to as a _card_, while _key_ refers to a [RSA Key](https://en.wikipedia.org/wiki/RSA_(cryptosystem)).


## 1. Configure your Local Machine

We need to install some utilities in the local machine provide the basic functionality to interfase with the YubiKey. We'll be using [GnuPG](https://gnupg.org):

> GnuPG is a complete and free implementation of the OpenPGP standard as defined by [RFC4880](https://www.ietf.org/rfc/rfc4880.txt) (also known as PGP). GnuPG allows you to encrypt and sign your data and communications; it features a versatile key management system, along with access modules for all kinds of public key directories. GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications. A wealth of frontend applications and libraries are available. **GnuPG also provides support for S/MIME and Secure Shell (ssh)**.

The easiest way to install GnuPG in macOS is by using [Homebrew](https://brew.sh):

```bash
brew install gnupg2 pinentry-mac
```

(in the newer versions, `gnupg2` ships with its own built-in `gpg-agent` )

If you bash profile does not specify a language with `LANG`, `gnupg2` will try to guess the best language for you. For some unknown reason, my installation decided that it'd be better in spanish and while the intention is appreciated, the command line utilities are a bit wonky in languages other than english.

However, this is a very quick fix. We'll set the appropiate `LANG` environment variable in the bash profile to `en`.

```bash
echo 'export LANG=en' >> ~/.zshrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
```

Along with GnuPG, we've installed a utility called `gpg-agent` which operates as a link between the YubiKey and the underlying GPG libraries. In order to improve the compatibility between macOS and the YubiKey, we need to add the following lines to the `gpg-agent` configuration file located in `~/.gnupg/gpg-agent.conf`


```
mkdir -p ~/.gnupg
```

nano ~/.gnupg/gpg-agent.conf

```
pinentry-program /usr/local/bin/pinentry-mac
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

You might want to add this as an alias, since it happens very frequently..

Finally, insert your YubiKey in a USB port and check if it is being correctly detected by running the command:

```bash
gpg --card-status
```

You should see the details of your YubiKey (card) in the console. Take note of the Serial Number of the card, it might be of use later in the setup.

> If you are having issues with the `gpg-agent` after a reboot, [check my newer post](https://www.edmundofuentes.com/blog/2018/08/20/quick-fix-for-yubikey-gpg-ssh/) for a quick-n-dirty fix.


Follow my previous guide with the steps to Initialize and configure your YubiKey


Tweak iOS Backups
ln -s /Volumes/SSD1TB/iOS\ Backups/ ~/Library/Application\ Support/MobileSync/Backup