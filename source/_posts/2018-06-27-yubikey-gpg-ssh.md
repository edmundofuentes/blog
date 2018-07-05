---
title: Yubikey GPG SSH setup
tags:
    - sculpin
    - markdown
categories:
    - personal
---

## Hello?
Hello
running
YubiKey 4 (a pair or more) https://www.yubico.com/products/yubikey-hardware/
macOS 10.13.5 High Sierra

AWS EC2 Ubuntu 18.04

## 1. CONFIGURE LOCAL MACHINE
Install GnuPG in macOS using [Homebrew](https://brew.sh)

```bash
brew install gnupg2 gpg-agent pinentry-mac
```

In case your Bash Profile is not

Set the language as English for GnuPG is wonky in other languages.

```bash
echo "export LANG=en" >> ~/.bash_profile
```


Add the following lines to `~/.gnugp/gpg-agent.conf`

The `gpg-agent` is the link between __

```nohighlight
pinentry-program /usr/local/bin/pinentry-mac
default-cache-ttl 3600
default-cache-ttl-ssh 3600
max-cache-ttl 7200
max-cache-ttl-ssh 7200
enable-ssh-support
```

Update your shell environment

```bash
echo "export GPG_TTY=$(tty)" >> ~/.bash_profile
echo "export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh" >> ~/.bash_profile
```

Quit your terminal and restart it.

Restart the GPG agent:

```bash
gpg-connect-agent killagent /bye
gpg-connect-agent /bye
```


Instert your card in a USB port and check if it is being correctly detected by running the command:

```bash
gpg --card-status
```

Take note of the Serial Number of the card, it might be of use later.


## 2. INITIALIZE THE CARD

Change the default PINs in the card, both the User PIN and the Admin PIN. In the beginning of this guide we selected the program `pinentry-mac`, this means a small window will popup in macOS whenever a PIN needs to be entered.

```bash
gpg --change-pin
```

Change the User PIN entering the option `1`, the default User PIN is `123456`.

Change the Admin PIN entering the option `3`, the default Admin PIN is `12345678`.


Now we'll change the Card Holder's data, this step is completely optional, but it's helpful when managing more than 1 card.

```bash
gpg --card-edit
```

We need to enable the admin mode for the following steps

```
gpg/card> admin
```

The console should say `Admin commands are allowed`. In the following steps your Admin PIN might be requested in order to modify the card's details.

Change the holder's name, it asks for the Surname (last name) and the Given name (first name) independently

```
gpg/card> name
```

Change the holder's sex

```
gpg/card> sex
```

Change the language to `en`

```
gpg/card> lang
```

We can now safely exit the console.

```
gpg/card> quit
```



## 3. GENERATE the RSA Keys on your YubiKey

By default, the cards ___ no keys, YubiKey 4 can create 3 different RSA-2048 keys:
- Signature Key
- Encryption Key
- Authentication Key


Run again the `gpg --card-status` command in your terminal, it should display the updated card info. At the bottom of the list are the 3 keys, which should not be set and should display as `[none]`

We'll use `gpg --card-edit` and we'll enable admin mode again by typing `admin` into the console

Generate the RSA Key

The following commands should be entered quickly to prevent the process to timeout. At any point the process might ask you for the User PIN or the Admin PIN, please pay attention to the pinentry dialogs.

```
generate
```

Options:
- Do not make a backup, this key will be used for SSH only, if the key is lost, the process can be done again. This way the private key will never leave your YubiKey. If you will also use this YubiKey to encrypt files or some other use, then you might consider making a backup.
- Enter the User PIN
- Set the expiration time. If you set your keys to expire, please remember to update ___  discipline.
- Enter the Holder's Real Name. Enter both the first and last name in the same field.  Preferably, this should match the Holder's name provided in the card initialization.
- Enter the Holder's Email.
- Optionally add a comment to the key
- Enter the Admin PIN to begin the key generation.

Wait a few seconds while the key is being generated.

At the end, you should see the following message:

```
public and secret key created and signed.
```

Press `<enter>` on the GPG console to see the card status. You should now see the signature of the created keys.

Now you can quit the GPG console

```
gpg/card> quit
```





## 4. VIEW THE PUBLIC KEY

Run the command

```bash
ssh-add -L
```

You should see the public key of the card.

If the console says `The agent has no identities.` you might have an error in your local machine settings. Check section 1 of this guide.

We'll save the Public Key to a file to make handling easier.

```bash
ssh-add -L > ~/.ssh/yubikey_gpg.pub
```

Now you have a __ key pair that can be used to authenticate __

It is highly recommended that you repeat this process for a second YubiKey in case of loss or damage to one of them.

## 5.A IMPORT YOUR PUBLIC KEY TO AWS EC2


https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws

## 5.B ADD THE PUBLIC KEY TO AN EXISTING SERVER'S AUTHORIZED KEYS

We'll be assuming Ubuntu 18.04 on AWS EC2, but the process should be more or less the same for any other distro, version or cloud provider. You'll need to use your existing `.pem` file to login and configure the remote server.

Copy the Public Key file from your local machine to the remote machine, enter this command on your local machine:

```bash
local> scp -i awskey.pem ~/.ssh/yubikey_gpg.pub <user>@<host>:~/.ssh/yubikey_gpg.pub
```

Once your Public Key is copied, log into the remote machine enter this command on the remote machine:

```bash
remote> cat ~/.ssh/yubikey_gpg.pub >> ~/.ssh/authorized_keys
```

Now you will have, __ both the original Identity File (.pem) and your YubiKey

### Disable the original Identity File (.pem)
If you'd like to disable logging-in


### Clean up the files in the remote server
Clean up the __

```bash
remote> rm ~/.ssh/yubikey_gpg.pub
```

## 5.C

DISABLE PASSWORD AUTHENTICATION ON THE SERVER

sudo nano /etc/ssh/sshd_config

Look for the option PasswordAuthentication, uncomment it and set it to no

PasswordAuthentication no


## Troubleshooting
Theories, not tested.

gpg: key generation failed: End of file.

gpg: error setting lang: Broken pipe

the `gpg-agent` might get __ . Fully quit your terminal and restart it, then restart the `gpg-connect-agent` daemon (step 1).


Reset your YubiKey 4: https://gist.github.com/pkirkovsky/c3d703633effbdfcb48c


## Sources & References


In no particular order:
- First Look Media "Configure SSH to use a Yubikey as a private key" https://github.com/firstlookmedia/firstlookmedia.github.io/wiki/Configure-SSH-to-use-a-Yubikey-as-a-private-key
- Simon Slangen, Make Use Of, "How To Authenticate Over SSH With Keys Instead Of Passwords" https://www.makeuseof.com/tag/how-to-authenticate-over-ssh-with-keys-instead-of-passwords/
- GnuPG.org https://www.gnupg.org/howtos/card-howto/en/ch03s03.html
- Paddy Steed, Engineer Better, "Yubikeys for SSH Auth" http://www.engineerbetter.com/blog/yubikey-ssh/
- YubiKey-Guide by drduh https://github.com/drduh/YubiKey-Guide
