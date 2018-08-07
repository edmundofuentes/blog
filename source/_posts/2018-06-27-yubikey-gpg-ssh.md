---
title: Configuring a Yubikey with GPG for SSH Authentication
tags:
    - ssh
    - yubikey
    - security
categories:
    - devops
---

This guide was tested on my current development setup:

- **Local:** macOS 10.13.5 High Sierra on a MacBook Pro 15-inch Touchbar
- **Remote:** AWS EC2 Ubuntu 18.04 LTS (Server, Bionic Beaver)

And for the hardware, I'm using a couple of [YubiKey 4](https://www.yubico.com/products/yubikey-hardware/). I highly recommended that you get at least a pair of them.

Note: throughout the guide and in the GnuPG references, the YubiKey is referred to as a _card_, while _key_ refers to a [RSA Key](https://en.wikipedia.org/wiki/RSA_(cryptosystem)).


## 1. Configure your Local Machine

We need to install some utilities in the local machine provide the basic functionality to interfase with the YubiKey. We'll be using [GnuPG](https://gnupg.org):

> GnuPG is a complete and free implementation of the OpenPGP standard as defined by [RFC4880](https://www.ietf.org/rfc/rfc4880.txt) (also known as PGP). GnuPG allows you to encrypt and sign your data and communications; it features a versatile key management system, along with access modules for all kinds of public key directories. GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications. A wealth of frontend applications and libraries are available. **GnuPG also provides support for S/MIME and Secure Shell (ssh)**.

The easiest way to install GnuPG in macOS is by using [Homebrew](https://brew.sh):

```bash
brew install gnupg2 gpg-agent pinentry-mac
```

If you bash profile does not specify a language with `LANG`, `gnupg2` will try to guess the best language for you. For some unknown reason, my installation decided that it'd be better in spanish and while the intention is appreciated, the command line utilities are a bit wonky in languages other than english.

However, this is a very quick fix. We'll set the appropiate `LANG` environment variable in the bash profile to `en`.

```bash
echo 'export LANG=en' >> ~/.bash_profile
```

Along with GnuPG, we've installed a utility called `gpg-agent` which operates as a link between the YubiKey and the underlying GPG libraries. In order to improve the compatibility between macOS and the YubiKey, we need to add the following lines to the `gpg-agent` configuration file located in `~/.gnupg/gpg-agent.conf`


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
echo 'export GPG_TTY=$(tty)' >> ~/.bash_profile
echo 'export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh' >> ~/.bash_profile
```

Close all your current terminal windows and restart the Terminal application.

Restart the `gpg-agent` service and update its settings:

```bash
gpg-connect-agent killagent /bye
gpg-connect-agent updatestartuptty /bye
gpg-connect-agent /bye
```


Finally, insert your YubiKey in a USB port and check if it is being correctly detected by running the command:

```bash
gpg --card-status
```

You should see the details of your YubiKey (card) in the console. Take note of the Serial Number of the card, it might be of use later in the setup.



## 2. Initialize the YubiKey
### 2.1 Change the PINs
In compliance with the standards, the YubiKey operates with two different PINs:

- **User PIN**: a 6-digit (or longer) PIN used to unlock and enable the card to perform operations such as signing, encrypting and authenticating.
- **Admin PIN**: a 8-digit (or longer) PIN used to configure the card.

The first thing we'll do is change the default PINs in the card, both the User PIN and the Admin PIN. In the beginning of this guide we selected the program `pinentry-mac` as the pin-entry mechanism. This is a simple application that displays a small pop-up window whenever a PIN needs to be entered. It will also display some additional information about the action that is being requested to authorize with the PIN, and the type of PIN that is being requested (User or Admin).

To change the PINs we use the utility:

```bash
gpg --change-pin
```

1. Change the User PIN entering the option `1`, the default User PIN is `123456`.
2. Change the Admin PIN entering the option `3`, the default Admin PIN is `12345678`.

### 2.2 Set the Card Holder's Data (optional)
This step is completely optional, but it's helpful when managing more than 1 card.

```bash
gpg --card-edit
```

The `--card-edit` command initializes a simple console. We first need to enable the admin mode entering:

```
gpg/card> admin
```

The console should say `Admin commands are allowed`. In the following steps your Admin PIN might be requested in order to modify the card's details.

1. Enter `name` to set the holder's name, it asks for the Surname (last name) and the Given name (first name) independently.
2. Enter `sex` to set the holder's sex
3. Enter `lang` to set the 2-letter language code ([see ISO 639-1](https://en.wikipedia.org/wiki/ISO_639-1))

Finally, you can enter `quit` to exit the console.

```
gpg/card> quit
```



## 3. Generate your RSA Keys on your YubiKey

The YubiKeys come blank, that is, without any preset RSA Keys. The YubiKey 4 can generate and store 3 different types of RSA-2048 keys:
- Signature Key
- Encryption Key
- Authentication Key


Run again the `gpg --card-status` command in your terminal and it should display the updated card info. The 3 types of keys are displayed at the bottom of the list, and they should not be set and should be displayed as `[none]`

We'll use `gpg --card-edit` again and we'll enable the admin mode by typing `admin` into the console.


The `generate` command provides some options for the generation of the keys. All the options should be entered quickly to prevent a timeout in the process. Please read ahead and fully understand the available options before running the command. At any point of the process it might ask you for the User PIN or the Admin PIN, please pay attention to the `pinentry` dialogs and enter the correct PIN when requested.

```
gpg/card> generate
```

#### Key generation options:

- Make a backup copy of the private key? **No**, do not make a backup. This card will be used for SSH Authentication only, which means that if the key is lost, you can have a backup _card_ to authenticate against your servers. If you don't make a backup copy then the private key will never leave your YubiKey. (However, if you plan to also use this YubiKey to encrypt files, sign emails or some other use, then you might consider making a backup.)
- Set the expiration time. If you set your keys to expire, also remember to periodically update your public keys.
- Enter the Holder's Real Name. Enter both the first and last name in the same field.  Preferably, this should match the Holder's name provided in the card initialization.
- Enter the Holder's Email.
- Optionally add a comment to the key

Wait a few seconds while the key is being generated.

At the end, you should see the following message:

```
public and secret key created and signed.
```

This means the YubiKey has successfully generate a new set of public-private key pairs and it has stored them on the device. 

Press `<enter>` on the GPG console to see the card status. You should now see the signature of the created keys at the bottom of the list. You can now quit the GPG console.

```
gpg/card> quit
```


## 4. Extract your Public Key

Run the following command in your terminal:

```bash
ssh-add -L
```

You should now see the public key of the card.

_If the console says `The agent has no identities.` you might have an error in your local machine settings. Check the Step 1 of this post._ 

We'll save the Public Key to a file to make handling it easier:

```bash
ssh-add -L > ~/.ssh/yubikey_gpg.pub
```

Now you have a secure key pair that can be used to authenticate in SSH or other services.  Remember, the _private_ key lives securely in your YubiKey and cannot be extracted, while your public key has been saved in the `.pub` file and can be shared.

## 5. Repeat for a second YubiKey

I highly recommended that you repeat this process for a second (or third) YubiKey in case of loss or damage to either one of them.


## 6.A Import your Public Key to AWS EC2

The AWS documentation has a simple step-by-step guide to import your public key into your AWS console panel.  After you have imported your public key, you can select it when launching a new EC2 instance. Sweet!

["Importing Your Own Public Key To Amazon EC2"](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws)

## 6.B Add your Public Key to an Existing Server's Authorized Keys List

I'll be assuming Ubuntu 18.04 on AWS EC2, but the process should be more or less the same for any other distro, version or cloud provider. 

You'll need to use your existing `.pem` file to login and configure the remote server. I recommend you to keep a SSH session open and then open _a second session_ to modify and test your server's settings. This way, if anything wrong were to happen, you could still revert the changes by using the first session while making sure you do not get locked out from your own server.

_If your server is not yet configured to authenticate SSH with Identity Files or Keys, [see my other post](http://localhost:8000/blog/2018/06/28/ubuntu-server-ssh-with-key-pairs)._

Copy the Public Key file from your local machine to the remote machine. You can use this one-liner by adjusting the location of the `awskey.pem` file in your local machine, and specifying the correct `<user>@<host>`:

```bash
local> scp -i awskey.pem ~/.ssh/yubikey_gpg.pub <user>@<host>:~/.ssh/yubikey_gpg.pub
```

Once your Public Key is copied, log into the remote machine in the second SSH session.  We will now append your new public key to the list of authorized keys in your server. Enter this command on the remote machine:

```bash
remote> cat ~/.ssh/yubikey_gpg.pub >> ~/.ssh/authorized_keys
```

That's it, we're done. Now you can use your YubiKey to log in to your server! However, you can still log in with the original Identity File (`.pem`), which might be desired or not.

### Disable the original Identity File (.pem)
If you'd like to disable logging-in with the original `.pem` file, we have to remove its public key from the `authorized_keys` list.

You could do something like:

```bash
remote> mv ~/.ssh/authorized_keys ~/.ssh/authorized_keys.backup
remote> touch ~/.ssh/authorized_keys
remote> cat ~/.ssh/yubikey_gpg.pub >> ~/.ssh/authorized_keys
```

Remember to double check your changes before logging out.


### Clean up the files in the remote server
If you like things neat and tidy, you should also remove the `.pub` file that was placed in the remote server.

```bash
remote> rm ~/.ssh/yubikey_gpg.pub
```

## 7. Logging-in with the YubiKey

The process to log in via SSH using your YubiKey is the same, except we'll skip the ugly `-i awskey.pem` part. Example:

```bash 
USING PEM FILE:  ssh -i ~/path/to/awskey.pem <user>@<host>
USING YUBIKEY:   ssh <user>@<host>
```

Nice!

When you try to log in, your local machine will detect that the SSH server requires an Identity File. Then, it will check the server's `authorized_keys` against the local `gpg-agent` which in turn will check in the YubiKey.  If the YubiKey provides a matching authorization public key, it'll request to unlock the card via the `pinentry` program. Once unlocked, the card will handle the authentication securely using it's private key. If everything matches (as it should), you're in!




## Troubleshooting
During my experimentation with this setup, I had a some random `gpg` errors and bugs in my local machine, such as `gpg: key generation failed: End of file.` and `gpg: error setting lang: Broken pipe`.

I have some theories that the underlying `gpg-agent` gets out of sync with your terminal and the card, and the procedure that usually worked for me was:

1. Fully quit your terminal and restart it.
2. Restart the `gpg-connect-agent` daemon as shown in the Step 1 of this post.


### Factory Reset your YubiKey
If something goes wrong, here's a quick Gist to [reset your YubiKey 4](https://gist.github.com/pkirkovsky/c3d703633effbdfcb48c). Bear in mind that you will loose your Private Keys and you will loose access to any service that is linked to your card's public key.


## Sources & References

Some of the articles, documentation and guides that I consulted, in no particular order:

- First Look Media: ["Configure SSH to use a Yubikey as a private key"](https://github.com/firstlookmedia/firstlookmedia.github.io/wiki/Configure-SSH-to-use-a-Yubikey-as-a-private-key)
- Simon Slangen (Make Use Of): ["How To Authenticate Over SSH With Keys Instead Of Passwords"](https://www.makeuseof.com/tag/how-to-authenticate-over-ssh-with-keys-instead-of-passwords/)
- GnuPG.org: ["Initialising the card](https://www.gnupg.org/howtos/card-howto/en/ch03s03.html)
- Paddy Steed (Engineer Better): ["Yubikeys for SSH Auth"](http://www.engineerbetter.com/blog/yubikey-ssh/)
- [YubiKey-Guide by drduh](https://github.com/drduh/YubiKey-Guide)
