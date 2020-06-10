---
title: Boss RC-202 Loop Station with the Nektar Pacer MIDI Foot Controller
tags:
    - hardware
    - midi
    - loop station
categories:
    - music
---

I spent quite a bit of time [researching commercially available options and gathering ideas to control the Boss RC-202 Loop Station with my feet](/blog/2020/04/25/custom-midi-foot-controller-part-1) . I even went as far as designing a [custom MIDI controller](/blog/2020/04/26/custom-midi-foot-controller-part-2), and when I was browsing Amazon for components I found the Nektar Pacer MIDI Foot Controller with very good reviews. While it is expensive at ~$220 USD, it is definitely cheaper than the solution I was thinking of building.

So I scratched all my plans to build a custom controller and I went ahead and bought the Pacer.

After messing around with it for a little while I think I've found the optimal settings to control the RC-202 in my workflow, which I'll detail below.  But first, some context from my previous post:

> The RC-202 is a _desktop_ loop station, which means that it's designed to be operated with your fingers, allowing for a much finer control than a simple two-pedal stompbox. However, I still need to be able to control some basic functions of the looper through a foot controller, to be able to use it while playing the guitar or any other instrument that requires both of my hands.
> 
> Luckily, the RC-202 supports external controls, but it's (artificially) limited in those. It supports 7 "switches" that can be assigned to one of 35 predefined functions, for example "Function #1: Switches track 1 between record/play", "Function #6:  Clears track 2", and so on. However, there's a catch since the 7 "switches" are not all equal:
> 
> - 2 of them are for an external dual footswitch, such as the Boss FS-6, connected through a 1/4" TRS jack (CTL1+CTL2 input).
> - 5 of them are for special MIDI Control Change (CC) messages that can be received through the MIDI IN connector and are fixed to CC 80 thru CC 84.

The Pacer has 11 footswitches, but only 10 of those can be mapped. They are ordered in two rows, the upper row has 4 switches, while the lower row has 6. It also supports 4 extra external footswitches, as well as 2 expresion pedals. All in all, I think it's a great flexible product, the build quality is on par with Roland / Boss pedals, and it has enough functionality to give me room to grow in case I ever upgrade to the RC-505.


## The Layout
While the Pacer has 10 configurable footswitches, the RC-202 allows at most 7 inputs. This gave me a little room to mess around until I found a nice _symmetrical_ layout that I liked.

I'm only using the center 8 switches (A, B, C, D, 2, 3, 4, 5) to control the RC-202, and I'm leaving the outermost switches `1` and `6` to control other devices.

<a href="/images/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/nektar-pacer-rc202-layout.jpg" class="no-underline" target="_blank">
    <img src="/images/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/nektar-pacer-rc202-layout.jpg" alt="Nektar Pacer RC-202 Layout" />
</a>


The next step is to define how each switch will be mapped, what signal will be sent out from the Pacer and how each signal will be assigned and configured in the RC-202. I drew this little table to help me out when configuring everything:


Footswitch |       Function      | Pacer Out  |  RC-202 In  | RC-202 Assignment
-----------|---------------------|------------|-------------|------------------
Preset     | cannot be mapped    | --         | --          | --
A          | Undo Track 1        | Relay 1    | CTL1        | FN 7
B          | Play/Stop All       | MIDI CC 84 | MIDI IN (5) | FN 16
C          | Play/Stop All       | MIDI CC 84 | MIDI IN (5) | FN 16
D          | Undo Track 2        | Relay 3    | CTL2        | FN 8
1          | not used            | Relay 2    | --          | --
2          | Play/Stop Track 1   | MIDI CC 82 | MIDI IN (3) | FN 3
3          | Play/Record Track 1 | MIDI CC 80 | MIDI IN (1) | FN 1
4          | Play/Record Track 2 | MIDI CC 81 | MIDI IN (2) | FN 2
5          | Play/Stop Track 2   | MIDI CC 83 | MIDI IN (4) | FN 4
6          | not used            | Relay 4    | --          | --


There are some things to note:

- Switches `B` & `C` are duplicated to keep it "symmetrical".
- Switches `1` & `6` are not used to control the RC-202, but I've mapped them to the `Relay 2` and `Relay 4` (`R2/4` jack in the Pacer) in order to control other simpler pedals in my setup (such as the Boss VE-1 Vocal Echo), or as an extra footswitch for the GT-1 / GT-1B. This will allow me to replace a regular external footswitch, like a Boss FS-6 or Boss FS-7.


## Configuring the Nektar Pacer
The Pacer can be configured directly on the device using the small display and the single knob. However, it's much faster to configure it using the [Web-based Open-Source Pacer Editor](https://francoisgeorgy.github.io/pacer-editor/#/) developed by [François Georgy](https://github.com/francoisgeorgy).  Even thought this editor is not an "official" utility by Nektar, it's recommended by the company on their own [Support Knowledge Base article about the Pacer](https://nektartech.com/creating-and-customizing-presets-for-pacer/).

The editor is pretty straight forward, and after tweaking the settings this is the overview of my custom preset:

<a href="/images/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/nektar-pacer-patch-rc202-overview.png" class="no-underline" target="_blank">
    <img src="/images/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/nektar-pacer-patch-rc202-overview.png" alt="Nektar Pacer RC-202 Patch Overview" />
</a>


If you'd like to try this layout, you can download [my RC-202 `.syx` file](/assets/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/netkar-pacer-patch-rc202.2020-06-10-033223.syx) and upload it to your Pacer following these steps:


1. Go to "Patch" on the top menu bar
2. Click on "Read patch from Pacer" to load your current settings.
3. Click on "Save patch to file" to download your current settings as a `.syx`.  Store this file as this will be your backup in case you want to revert to your custom settings.
4. Click on "Load patch from file" and select [my RC-202 `.syx` file](/assets/posts/2020-06-05-boss-rc-202-nektar-pacer-midi-foot-controller/netkar-pacer-patch-rc202.2020-06-10-033223.syx)
5. Finally, click on "Send patch to Pacer" to upload the custom preset to your Pacer.


After this is done, you can unplug your Pacer and restart it. Then, access the `A1` preset and it should show `RC202` on the display. That's it.


## Configuring the Boss RC-202
Unlike the Pacer, the Boss RC-202 cannot be configured from a computer, at least as far as I know.  This means that the configuration must be done using the tiny 3-character display on the RC-202.  However, the procedure is actually very simple.

I recommend that you read first the [Boss RC-202 Owner's Manual (EN)](https://www.boss.info/global/support/by_product/rc-202/owners_manuals/2b3c1c0a-7ea1-42b3-9c81-ef33cf05aaa0/) followed by the [Boss RC-202 Parameter Guide (EN)](http://eg.boss.info/support/by_product/rc-202/owners_manuals/352020).  The actual information we need is on the Parameter Guide, as it includes the complete list of assignments and functions available in the device. (Why is it a separate document though? Makes no sense to me)

To ease the configuration process, I've simplified the map table:

CTL Source | CTL Target 
-----------|------------
`Ct1`      | `7`
`Ct2`      | `8`
`EHP`      | _skip_
`C80`      | `1`
`C81`      | `2`
`C82`      | `3`
`C83`      | `4`
`C84`      | `16`

To configure the RC-202, you have to press [SETUP] once, then press RING MODE [CTL] once to enter the CTL Assignment menu. In the menu, the display will blink between the current CTL Source (`Ct1`, `Ct2`, etc.) and its current CTL Target function. Use the [VALUE] knob to change the CTL Target, and _press_ the [VALUE] knob to configure the next CTL Source in the list.

## Connecting the devices
The final step is to connect both devices:
 
 - Connect a MIDI cable from the Pacer's MIDI Out to the RC-202's MIDI IN jack
 - Connect a 1/4" TRS cable from the Pacer's `R2/4` jack¹ to the RC-202's `CTL1/CTL2` jack.
 
Power on both devices from a 9V DC adapter and you're done. 

## General Notes / Troubleshooting
- The Boss RC-202 stores the CTL assignments as _bank settings_, instead of _global settings_. This means that the CTL configuration must be done once per each bank. If you never record anything in the built-in memory, then this should not be a problem since you could only configure the first bank and be done with it.  However, if you want it working in all 8 banks, you will have to configure it 8 times.
- Following the _bank settings_ issue on the RC-202, I'm still not 100% sure _how_ or _when_ the settings are saved on the RC-202.  Sometimes I can enter [SETUP], adjust the CTL settings, and [EXIT] and the settings will be persisted when restarting the RC-202. But sometimes not.  I have also tried to write a "blank" phrase after modifying the settings and this seems to be the most consistent method.
- ¹ For some reason, the Relay outputs appear to be flipped.  That is, the jack marked as `R1/3` on the Pacer responds to the settings made for the Relays 2 & 4, and the jack marked as `R2/4` on the Pacer responds to the settings for Relays 1 & 3. I'm not certain if the issue is in the Editor software or if it's a bug in the Pacer's firmware, but for now I'm swapping the plug to the other jack.
- I'd like to replace the semi-transparent labels for each footswitch.
- I might open up the Pacer sometime soon to see what's inside. I'll document my findings