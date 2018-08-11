---
title: Fixing Subpixel Anti-Aliasing Issues on Dell External Displays in macOS High Sierra
tags:
    - macos
    - egpu
    - workstation
categories:
    - fixes
---


After the latest update to macOS 10.13.6 _some_, but not all, of my external monitors connected through an eGPU on High Sierra started misbehaving and having issues with subpixel anti-aliasing rendering.


The issue can be described as blurry or fuzzy text with a noticeable case of color bleed that was mostly apparent when rendering text. For example, green text would have an irritating orange "halo" around it, which made it look dirty and very hard to read, even at normal font sizes.


> **Note:** I forgot to take pictures of the display issues to better describe the problems I was having, and I'd rather not revert the changes just to show you how badly it looked.

The weirdest thing is that it only happened on the displays that were connected using a DisplayPort cable, but not on HDMI. If I dragged a window into the DisplayPort monitor the issue would show up, but it'd revert when dragging the same window into the HDMI monitor. I knew it had to be a software or configuration problem caused by the latest macOS update.

## My Setup


So far, I've been enjoying the superb screen real estate provided by 3 2560x1440 monitors powered by a RX 580 eGPU. It allows me to simultaneously have a full-screen IDE, browser windows, terminal sessions and dashboards, without a noticeable hit in performance. 

Here's my current setup:

- MacBook Pro 15-inch (2016, 2.7 GHz Intel Core i7 quad-core, 16 GB RAM, discrete AMD Radeon Pro 460 4GB) on macOS High Sierra 10.13.6, running in clamshell mode (lid closed).
- [ASUS ROG Radeon RX 580 8GB GPU](https://www.asus.com/Graphics-Cards/ROG-STRIX-RX580-O8G-GAMING/) inside a [Sonnet eGFX 550 Breakaway Box](https://www.sonnetstore.com/collections/egpu-expansion-systems/products/egfx-breakaway-box-550). The GPU has 5 ports: 2 HDMI, 2 DisplayPort and 1 DVI.
- 3 [Dell U2515H](https://www.dell.com/en-us/work/shop/cty/pdp/spd/dell-u2515h-monitor) (25-inch, QHD 2560x1440) displays connected to the eGPU. 1 monitor is connected via HDMI and the other 2 are connected with DisplayPort.

## The Issue

After poking around for a while and reading through a lot of forums and posts, I finally discovered the underlying issue that was creating the rendering problems.

There are two main color spaces in which a display can be driven: RGB and YCbCr. I'm not an expert in color nor display theory, so I can't tell you the advantages of each color space mode. However, I do know that every display is _optimized_ to be driven in a specific color mode, just like each display has an optimal native resolution.

For some reason, macOS decided to drive _some_ of my Dell monitors in YCbCr, which in turn forced the Dell monitor to apply some post-processing signal "correction" to convert it to RGB, and **that** conversion is what was causing the anti-aliasing issues.

Upon closer examination of the monitor properties inside the macOS system profiler, I noticed that all 3 monitors show up as the same exact _model name_ made by the same vendor, but they have a different _product ID_ depending if they are connected through HDMI or DisplayPort. This means that even thought the monitors are physically the same, they are not considered as such since they have a different `productID`, and the system accordingly applies a different configuration mode. Why? Because fuck you.



## The Fix
However, not all is lost.  The important operational information of a display is stored in a metadata format called [Extended Display Indentification Data (EDID)](https://en.wikipedia.org/wiki/Extended_Display_Identification_Data), which is supposedly communicated to the host when connecting, or something like that. In my case, it wasn't happening correctly, but macOS allows to override any display configuration for this kind of issues, I suppose. Therefore, we must _simply_ provide a new configuration file that overrides the default for my monitors and makes macOS force RGB mode in all.

This configuration file is a special XML-like format that includes the EDID data. The fix is to generate a new configuration file for the monitors in which we _patch_ only the EDID data to specify RGB mode.

### 1. Generate EDID override file settings for your display

This problem appears to be common, so we will use a [script by Andrew Daugherity](https://gist.github.com/adaugherity/7435890) that does all the hard work of reading the current configuration and generates a set of patched configuration files.

The script `patch-edid.rb` is written in Ruby and is meant to be run in your desktop, enter these commands in your terminal:

```bash
cd ~/Desktop
curl -O https://gist.githubusercontent.com/adaugherity/7435890/raw/patch-edid.rb
ruby patch-edid.rb
```

This will download the script from GitHub and run it, generating configuration files for all your monitors currently in use. It will create a directory in your Desktop for each `DisplayVendorID` and inside of it a file for each `DisplayProductID`.

Take note of the information displayed when you ran the script. It will list all your connected monitors with the `model`,  `vendorid` and `productid` for each one. In my case, the list I got was:

```
found display 'DELL U2515H': vendorid 4268, productid 53359, EDID .....
found display 'DELL U2515H': vendorid 4268, productid 53359, EDID .....
found display 'DELL U2515H': vendorid 4268, productid 53360, EDID .....
```

Since I know that 2 monitors are connected with DisplayPort and 1 is connected with HDMI, I can work out that the `productid 53359` corresponds to the DisplayPort ones.

For my Dell U2515H displays, the vendor is `DisplayVendorID-10ac` so I got two configuration files: 

```
DisplayVendorID-10ac/
    DisplayProductID-d06f
    DisplayProductID-d070
```

Convert the last 4 characters of the DisplayProductID to decimal:

```
0xd06f --> 53359
0xd070 --> 53360
```

Great! Now I know that I should only override the `DisplayProductID-d06f` in order to fix the problems in my monitors connected via DisplayPort.


### 2. Place the files in the system folder

The next step is really simple (in theory): place the patched configuration file in the correct directory in the path `/System/Library/Displays/Contents/Resources/Overrides/` and reboot. However, in practice it's much more complicated.

Newer macOS releases ship with a feature called "System Integrity Protection" (SIP), also known as "rootless mode", that prevents any user from modifying some system directories, not even `root` nor `sudo` are allowed. This is great for malware protection, but it's a pain when you need to fix or patch your system.

> **Note:** macOS disables this for a reason, be extra careful when modifying system files. It can mess up your installation forcing you to re-install macOS and/or you might lose all your data and files. I take no responsibility.

#### Boot into Recovery Mode
The quickest way to getting around this security measure is to reboot your computer into Recovery Mode, perform the changes, and then boot back as normal.

To boot into Recovery Mode, turn off the computer and then press and hold `Cmd + R` while you turn it back on. The boot-up should be slower than normal, this is normal. Recovery Mode is a "live" and minimal macOS environment, but it gives you a some basic but powerful tools that we'll use to modify our dormant system.

#### Mount your File System
Since my SSD is encrypted using FileVault, it is not mounted when booting into Recovery.  To be able to operate on it you have to mount it. Open Disk Utility from the main Recovery window, then look for your disk on the sidebar and press on the _Mount_ button at the top right of the window. It'll take a moment and then it'll ask you for the encryption key in order to be able to unlock it and mount it. Type your password in the popup dialog box.

Once the main filesystem is mounted, we'll open a Terminal window. On the main Recovery window, look in the menu bar in Utilities > Terminal.

Note that in this _live_ environment, `/` corresponds to the current live OS, and your regular root directory is inside the `/Volumes` path. For example, your `Desktop` folder would be:

```bash
~/Desktop  -->  /Volumes/Macintosh\ HD/Users/<myuser>/Desktop
```

Double check the name under which your default partition was mounted, it most likely is `Macintosh\ HD` but it depends on your setup. Therefore, your regular root directory should be `/Volumes/Macintosh\ HD/`.

> **Tip:** the easiest way to navigate through your file system is by letting bash auto-complete your directories by using the `tab` key on the terminal. It'll take care of spaces and other special characters that you might have in your paths.

#### Create the Override Directory and Place the Patched File

In order for the override to be read and used by macOS, it should be placed according to the structure: `/System/Library/Displays/Contents/Resources/Overrides/<VendorID>/<ProductID>`

We'll first create the DisplayVendorID directory. In my case the VendorID is `DisplayVendorID-10ac`, so I'll run the following command:

```bash
mkdir /Volumes/Macintosh\ HD/System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-10ac
```

Now, we'll have to copy the patched file into the newly created override directory. I ran the `patch-edid.rb` script from the Step 1 in my Desktop, so the files were generated there. I will only override the `DisplayProductID-d06f` file, so the copy command in my case is:


```bash
cp /Volumes/Macintosh\ HD/Users/<myuser>/Desktop/DisplayVendorID-10ac/DisplayProductID-d06f /Volumes/Macintosh\ HD/System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-10ac/
```

Check that the file was correctly copied into the directory:

```bash
ls /Volumes/Macintosh\ HD/System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-10ac
```


You can now shut down the computer and reboot normally into macOS.


### 3. Test and Adjust

Assuming you were able to boot back into your normal macOS environment, we should now check if the override is being used or not.

Open your displays information pane from the menu bar: Apple Menu > About This Mac > Displays Tab.

You should see your monitors, if the override was successful  the _names_ displayed on the list should say `forced RGB mode`. If so, then the patched file is being correctly detected by the system and macOS is now driving the displays in RGB mode.

The issue should be fixed by now, but just in case, make sure to enable the global Anti-Aliasing setting in macOS.

1. On Apple Menu > System Preferences > General
2. Select _"Use LCD font smoothing when available"_ at the bottom of the preference pane


Enjoy your crisp monitor!

## References
- Mathew Inkson: ["Force RGB mode in Mac OS X"](http://www.mathewinkson.com/2013/03/force-rgb-mode-in-mac-os-x-to-fix-the-picture-quality-of-an-external-monitor#comment-15886)
- Andrew Daugherity: ["patch-edid.rb" Gist on GitHub](https://gist.github.com/adaugherity/7435890)