---
title: Quick Fix for Yubikey GPG for SSH Auth issues in macOS
tags:
    - ssh
    - yubikey
    - security
    - macos
categories:
    - devops
---

Sometimes after a reboot, my YubiKey card is not being detected when trying to use it to authenticate an SSH session, making the SSH connection fail with a `Permission denied (publickey).` error.

To check my card status, I run the `ssh-add -L` which should print my card's public key, but instead it shows this error:


```bash 
$ ssh-add -L
Error connecting to agent: No such file or directory
```

After a lot of reading and tinkering, I'm still not sure what the underlying issue is, but I've found that forcefully restarting the `gpg-agent` always fixes the issue after a system restart:

```bash
gpg-connect-agent killagent /bye
gpg-connect-agent updatestartuptty /bye
gpg-connect-agent /bye
```


From this, the quick-n-dirty solution is to add that command to as a bash alias by appending this line to the end of the `~/.bash_profile` file:


```bash
alias gpgreset='gpg-connect-agent killagent /bye; gpg-connect-agent updatestartuptty /bye; gpg-connect-agent /bye'
```

If you prefer one-liners, you can paste this command in your terminal window and it'll append the line to the end of your bash profile file:

```bash
echo "alias gpgreset='gpg-connect-agent killagent /bye; gpg-connect-agent updatestartuptty /bye; gpg-connect-agent /bye'" >> ~/.bash_profile
```

Now quit Terminal (`⌘+Q`) and re-open it.

You should now be able to type `gpgreset` in your terminal to trigger a quick restart of the `gpg-agent`, which should fix any issue you are having with your YubiKey card.