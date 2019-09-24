---
title: Enabling NTP Time Synchronization in Ubuntu 18.04
tags:
    - macos
    - webdev
categories:
    - webdev
draft: yes
---

Requires Brew


```bash
brew install beanstalkd
```


There are some tools recommended by the __ __ https://github.com/beanstalkd/beanstalkd/wiki/Tools


For me, the simplest and most straight-forward is the PHP-based [beanstalk_console](https://github.com/ptrofimov/beanstalk_console) by [ptrofimov](https://github.com/ptrofimov)


To locally install the project, requires Composer, if you don't already have Composer, installation is as simple as running:

```bash
brew install composer
```

(you can quickly check if it's installed by `composer --version` on the Terminal)


With composer


```bash
composer create-project ptrofimov/beanstalk_console -s dev path/to/install
```


create a `run.sh` file that will launch the local PHP server and open a new tab on Chrome pointing to it.

```bash
#!/bin/bash

# CD into the script's actual directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd ${DIR}

open -a "Google Chrome" "http://127.0.0.1:8005"

php -S 127.0.0.1:8005 -t public
```

And make it executable

```bash
chmod +x run.sh
```


After running, you should see 

```
PHP 7.1.23 Development Server started at Tue Sep 24 18:12:18 2019
Listening on http://127.0.0.1:8005
Document root is /path/to/beanstalk_console/public
Press Ctrl-C to quit.
```

That's it!