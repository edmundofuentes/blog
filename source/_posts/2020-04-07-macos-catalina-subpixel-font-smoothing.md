---
title: Fixing Subpixel Anti-Aliasing Issues on LCD External Monitors in macOS Catalina
tags:
    - macos
    - egpu
    - workstation
categories:
    - fixes
draft: yes
---

I've recently changed my setup and consolidated on a Mac Mini with an eGPU for my home workstation, and I've been having issues with subpixel anti-aliasing font rendering, again. I'm very picky with my displays, since I stare at them 10+ hours per day, and I even wrote a [very similar entry a couple of years ago](blog/2018/08/10/macos-external-display-antialiasing/) about some issues I was having with my last setup including external monitors. 

Everyone warned me not to update to macOS Catalina, but the new Mac Mini came with it so I thought I'd give it a try. I regret it now. The issue I'm having can be described as blurry or fuzzy text throughout the OS, with the problem being more apparent on some specific applications.

Sure, it might also be that (i) I'm getting older and my eyesight is deteriorating, (ii) I'm developing a severe case of [Computer Vision Syndome](https://en.wikipedia.org/wiki/Computer_vision_syndrome), or (iii) I'm bored of being in lockdown.


## My Setup

- Mac Mini (2018, 3.2 GHz Intel Core i7 six-core, 32 GB RAM) on macOS Catalina 10.15.4.
- [ASUS ROG Radeon RX 580 8GB GPU](https://www.asus.com/Graphics-Cards/ROG-STRIX-RX580-O8G-GAMING/) inside a [Mantiz Venus (MZ-02) eGPU Enclosure](https://mymantiz.com/products/mz-02-venus). The GPU has 5 ports: 2 HDMI, 2 DisplayPort and 1 DVI.
- 3 [Dell U2518D](https://www.dell.com/en-us/work/shop/cty/pdp/spd/dell-u2518d-monitor) (25-inch, QHD 2560x1440) displays connected to the eGPU. 1 monitor is connected via HDMI and the other 2 are connected with DisplayPort.

## The Issue

Around text/font smoothing.

I did a lot of reading, so I'll try to summarize the explanation.

In order to improve the perceived quality and readability of text,ei __ smoothing __ that draw __ intermediate pixels between boundaries.  This is known as subpixel aliasing. The purpose of this, is that instead of having a "sharp edge" (a sudden contrasting change between two adjacent pixels), you have a smoother gradient that is more confortable for the human eyes.  The final effect strives to appear as printed text on paper is.  However, this __ is a ___ too little smoothing and the text looks sharped and ragged, too much smoothing and it becomes a fuzzy blob in the screen.

Traditionally, font rendering was a shared arrangement between the OS, the graphics card and _the display itself_.  This means that some displays can and do apply their own smoothing for texts. If you display supports it, try messing around with the `Sharpness` configuration in your monitor's Menu (likely under a "Color" or "Picture" submenu).  If you can see any change in the rendered text in the screen, then it means your monitor is applying it's own smoothing to the text.

To further simplify how this works, let's say that there is a "special signal" that the OS or Graphics Card can send to the display to indicate whether a specific area of the display is text or regular graphics. If the display receives this signal and supports text smoothing, it applies its own interpretation of the subpixel  algorithm and smooths out the text.

We'll call this traditional method "**LCD Smoothing**" from here on.

Since macOS Mojave (10.14), Apple decided to ditch the traditional LCD Smoothing and they implemented a new rendering method which does not depend on the display.  We'll call this new method "**macOS Smoothing**".
 
 In Mojave you could turn it off __ and the UI would fallback to the traditional LCD smoothing method. .. here's the catch.. in macOS Catalina Apple actually _removed_ the functionality from the OS itself.


However, the "feature" alkjsdflakjsdklfasdf is still configurable and you can disable it, but now the UI won't fallback to the default.   This means that the whole UI 

OS Smoothing has been optimized for Retina™ Displays (HiDPI, >220ppi, 2x scaling) and I have no doubt that it offers serious benefits for Apple devices, and it gives total control of the __ rendering process to the OS, instead of depending on the interpretation of each display manufacturer.

However, it does not play very nicely with traditional "LoDPI" (~110ppi, 1x scaling) displays. And this is the core of the issue.

In my head, I picture it as a "special signal" that the OS sends to the display.  I'm not sure if I'm correct, but this makes sense to me.



## The Fix

There are [many](https://apple.stackexchange.com/a/337871) [posts](https://angristan.xyz/2018/09/how-to-fix-font-rendering-macos-10-14-mojave/) [in](https://www.howtogeek.com/358596/how-to-fix-blurry-fonts-on-macos-mojave-with-subpixel-antialiasing/) [the](https://colinstodd.com/posts/tech/fix-macos-catalina-fonts-after-upgrade.html) [internet](https://forums.macrumors.com/threads/the-subpixel-aa-debacle-and-font-rendering.2184484/) that show how to enable or disable macOS Smoothing.  The important bit is that we can either enable/disable it _globally_ or _per-application_.

You can run any of the following commands in your Terminal and then do a simple Logout cycle in macOS to apply the changes.

#### Disable macOS Smoothing globally
```
defaults write -g CGFontRenderingFontSmoothingDisabled -bool False
```

#### Disable macOS Smoothing per application
```
defaults write {{BUNDLE}} CGFontRenderingFontSmoothingDisabled -bool False
```

The command uses the `Bundle ID` of the target application, for example `Safari.app` is `com.apple.Safari`.

#### Enable and configure LCD Smoothing (globally) (3: strong smoothing, 2: medium, 1: low)
```
defaults -currentHost write -globalDomain AppleFontSmoothing -int 3
```


### Revert changes
To revert the changes globally
```
defaults write -g CGFontRenderingFontSmoothingDisabled -bool True
```

To revert the changes per application
```
defaults delete {{BUNDLE}} CGFontRenderingFontSmoothingDisabled
```


However, the features can be enabled per application.

The applications that I use the most are Chrome (WebKit renderer) and JetBrains IDEs (Java renderer)

For some applications, Chrome/WebKit/Electron based,


The applications can fallback to the traditional method.

Do note that while the application itself will be rendered correctly, but any UI that is provided by macOS ("Open.." dialog, pop-ups, menu bar, etc.) will __ and it won't have __ which means it'll look bad.


## The Snippet

I wrote a quick PHP snippet to simplify the process of tweaking the rendering per application. I know, PHP is a weird choice for this type of scripts, but it works the same.

Save the following snippet as `tweak-font-rendering.php` and execute it in the Terminal as:
 
```
php tweak-font-rendering.php
 ```

You can add your own applications inside the `$applications` list, or if you know the Bundle IDs you can add them inside the `$bundles` list.

```php
<?php

const MDLS = 'mdls -name kMDItemCFBundleIdentifier -r ';
const WRITE_DEFAULTS = 'defaults write {{BUNDLE}} CGFontRenderingFontSmoothingDisabled -bool False';

// List all your applications that you want to tweak, the script will automatically lookup their BundleIDs
$applications = [
  '/Applications/Google Chrome.app',
  '/Applications/Slack.app',
  '/Applications/Franz.app',
  '/Applications/Atom.app',

  // the JetBrains Toolbox creates a weird intermediate launcher, so we cannot look them up from their '.app'
  //'/Users/mundofr/Applications/JetBrains Toolbox/PhpStorm.app',
  //'/Users/mundofr/Applications/JetBrains Toolbox/GoLand.app',
];

// If you know the actual BundleIDs of your applications, you can list them here:
$bundles = [
  'com.jetbrains.PhpStorm',
  'com.jetbrains.goland',
];


foreach ($applications as $app) {
  echo "-> " . $app;

  // Find the Bundle ID
  $bundle = shell_exec(MDLS . '"' . $app . '"');
  echo "  [" . $bundle . ']' . PHP_EOL;
  $cmd = str_replace('{{BUNDLE}}', $bundle, WRITE_DEFAULTS);
  echo "   " . $cmd . PHP_EOL;

  shell_exec($cmd);
}

foreach ($bundles as $bundle) {
  echo "-> [" . $bundle . ']' . PHP_EOL;
  $cmd = str_replace('{{BUNDLE}}', $bundle, WRITE_DEFAULTS);
  echo "   " . $cmd . PHP_EOL;

  shell_exec($cmd);
}

// To finish, enable LCD font smoothing!
// The effect can be configured by changing the last number in this command:  3: strong, 2: medium, 1: low
shell_exec("defaults -currentHost write -globalDomain AppleFontSmoothing -int 2");
```


### Final Thoughts
I'm still not 100% convinced about this solution, but at least it improved the readability of my most used applications.  The way I see it there are two options

* Go with the flow with Apple, embrace the _Retina™ Everywhere_ proposal, and replace all my displays with 27" 5k monitors. This will be stupidly expensive.
* Downgrade to Mojave for the time being. Apple is unlikely to add back the functionality that they've removed, so this is only a temporary solution for an inevitable problem.

I think I might be downgrading soon.