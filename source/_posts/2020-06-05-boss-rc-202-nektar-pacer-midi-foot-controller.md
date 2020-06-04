---
title: Boss RC-202 with the Nektar Pacer MIDI Foot Controller
tags:
    - hardware
    - midi
    - loop station
categories:
    - music
draft: yes
---

I spent quite a bit of [researching commercially available options and gathering ideas](/blog/2020/04/25/custom-midi-foot-controller-part-1) to control my Boss RC-202 Loop Station with my feet. I even went as far as designing a [custom ](/blog/2020/04/26/custom-midi-foot-controller-part-2) __ but then I found the Nektar Pacer MIDI Foot Controller, __

While expensive at ~$220 USD, it was definitely cheaper than the solution I was thinking of building.

So I went ahead and ordered it, and after messing around with it for a little while I think I've found the perfect ___ to control the RC-202.

room to grow in case I ever upgrade to the RC-505.

From my previous post:

> The RC-202 is a _desktop_ loop station, which means that it's designed to be operated with your fingers, allowing for a much finer control than a simple two-pedal stompbox. However, I still need to be able to control some basic functions of the looper through a foot controller, to be able to use it while playing the guitar or any other instrument that requires both of my hands.
> 
> Luckily, the RC-202 supports external controls, but it's (artificially) limited in those. It supports 7 "switches" that can be assigned to one of 35 predefined functions, for example "Function #1: Switches track 1 between record/play", "Function #6:  Clears track 2", and so on. However, there's a catch since the 7 "switches" are not all equal:
> 
>  - 2 of them are for an external footswitch, such as the Boss FS-6, connected through a 1/4" TRS jack (CTL1+CTL2 input).
> - 5 of them are for special MIDI Control Change (CC) messages that can be received through the MIDI IN connector and are fixed for CC 80 to CC 84.

This means that __




The Pacer has 11 footswitches, but only 10 of those can be mapped. They are ordered in two rows, the upper ___

Preset, A, B, C, D



## The Layout
aksldfjlakjsdf

The Pacer has 10 configurable footswitches, but the RC-202 allows at most 7 inputs. This gave me a little room to mess around..

I'm only using the center 8 switches to control the RC-202.

Leaving the outermost switches `1` and `6` to control other devices.




## Mapping the Footswitches
The next step is to define how each switch will be mapped, what signal will be sent out from the Pacer and how each signal will be assigned and configured in the RC-202.


Footswitch |       Function      | Pacer Out  |  RC-202 In  | RC-202 Assignment
-----------|---------------------|------------|-------------|------------------
Preset     | cannot be mapped    | --         | --          | --
A          | Undo Track 1        | Relay 1    | CTL1        | FN 7
B          | Play/Stop All       | MIDI CC 84 | MIDI IN (5) | FN 16
C          | Play/Stop All       | MIDI CC 84 | MIDI IN (5) | FN 16
D          | Undo Track 2        | Relay 2    | CTL2        | FN 8
1          | not used            | Relay 3    | --          | --
2          | Play/Stop Track 1   | MIDI CC 82 | MIDI IN (3) | FN 3
3          | Play/Record Track 1 | MIDI CC 80 | MIDI IN (1) | FN 1
4          | Play/Record Track 2 | MIDI CC 81 | MIDI IN (2) | FN 2
5          | Play/Stop Track 2   | MIDI CC 83 | MIDI IN (4) | FN 4
6          | not used            | Relay 4    | --          | --


Things to note:

- Switches `B` & `C` are duplicated to keep it "symmetrical".
- Switches `1` & `6` are not used to control the RC-202, but I've mapped them to the `Relay 3` and `Relay 4` in order to control other simpler pedals in my setup (such as the Boss VE-1 Vocal Echo), or as an extra footswitch for the GT-1 / GT-1B. This will allow me to replace a regular external footswitch, such as one of my Boss FS-7 footswitches.


## Configuring the Nektar Pacer

The Pacer can be configured directly __ using the small display and the rotary encoder. However, it's much faster to configure it using the [Web-based Open-Source Pacer Editor](https://francoisgeorgy.github.io/pacer-editor/#/) developed by [François Georgy](https://github.com/francoisgeorgy).  Even thought this editor is not an "official" utility by Nektar, it's recommended by the company on their own [Support Knowledge Base article about the Pacer](https://nektartech.com/creating-and-customizing-presets-for-pacer/).


## Configuring the Boss RC-202
kjasdlkfjasldjfkasdf

Parameter Guide from Boss

The complete list of assignments and functions is available in the [Boss RC-202 Parameter Guide (EN)](http://eg.boss.info/support/by_product/rc-202/owners_manuals/352020).

## Next __ future __ things





On a future .. I might open it up to see if I can replace the microcontroller inside of it __, 
and to swap the default labels with some custom printed ones.