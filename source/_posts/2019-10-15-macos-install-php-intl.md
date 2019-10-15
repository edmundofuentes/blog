---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - macos
    - webdev
categories:
    - webdev
draft: yes
---


brew update
brew install php@7.3
brew link php@7.3

This guide requires [Brew](https://brew.sh).


```
php -m | grep intl
```


## Install PEAR

Verify your installation with
```bash
pear version
```


## Install icu4c

```bash
brew install icu4c
```




References:

https://jasonmccreary.me/articles/install-pear-pecl-mac-os-x//