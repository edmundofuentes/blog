---
title: Configure Beanstalkd and Utilities on macOS
tags:
    - macos
    - webdev
categories:
    - webdev
---

Beanstalkd is a ["simple, fast work queue"](https://beanstalkd.github.io/). Originally created for web applications, it's so simple that it can be used on any project that requires async job processing. In my case, it's a must for any web project of medium complexity. Thanks to its simplicity and popularity, the beanstalkd service has been compiled and ported to most OSs, including macOS, and there are client libraries for almost every language.

I've written this guide to install and configure the core beanstalkd service on macOS, as well as a helper monitor utility to simplify my web development workflows. (_This guide has only been tested on macOS High Sierra and macOS Catalina._)

## Install Beanstalkd

Installation requires [Brew](https://brew.sh/), _the_ package manager for macOS. With brew, there's already a published tap/formula for beanstalkd, so you only need to type:


```bash
brew install beanstalkd
```

As a note, macOS is not very friendly to some services. If you think your beanstalkd installation is misbehaving, you can nudge it with:

```bash
brew services restart beanstalkd
```


## Beanstalkd monitor and utilities

There are some tools recommended by the [official beanstalkd project](https://github.com/beanstalkd/beanstalkd/wiki/Tools)
to monitor and debug the service. For me, the simplest and most straight-forward monitor is the PHP-based [beanstalk_console](https://github.com/ptrofimov/beanstalk_console) by [ptrofimov](https://github.com/ptrofimov). Also, since this is a PHP project, we can install it locally in macOS and run it with the built-in PHP standalone server.


To locally install the project, you will need [Composer](https://getcomposer.org/), a PHP dependency manager (you can quickly check if it's installed by running `composer --version` on the Terminal). If you don't already have Composer, installation is as simple as typing:

```bash
brew install composer
```


Once Composer is installed, this one-liner will install and configure the beanstalk_console monitor (replace `path/to/install` to your desired install location):


```bash
composer create-project ptrofimov/beanstalk_console -s dev path/to/install
```


We'll also create a helper `run.sh` script inside the `path/to/install` directory. This script prepares your dev environment by restarting Beanstalkd, launching a local PHP server with the monitor, and finally opening a new tab on Chrome pointing to it (`127.0.0.1:8005`).

```bash
#!/bin/bash

# CD into the script's actual directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd ${DIR}

# Restart the core Beanstalkd service
brew services restart beanstalkd

# Launch a new Chrome window pointing to the console
open -a "Google Chrome" "http://127.0.0.1:8005"

# Start the local PHP server with the beanstalk_console
php -S 127.0.0.1:8005 -t public
```

Don't forget to make it executable:

```bash
chmod +x run.sh
```


After running the script, you Terminal should display:

```bash
$> ./run.sh

PHP 7.1.23 Development Server started at Tue Sep 24 18:12:18 2019
Listening on http://127.0.0.1:8005
Document root is /path/to/beanstalk_console/public
Press Ctrl-C to quit.
```

That's it!