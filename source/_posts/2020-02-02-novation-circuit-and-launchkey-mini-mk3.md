---
title: Using a Novation Circuit with the Launchkey Mini Mk3 keyboard controller
tags:
    - novation
    - circuit
    - launchkeymini
    - midi
categories:
    - music
---

[Novation](https://novationmusic.com) has recently launched an updated version of their [Launchkey Mini (Mk3)](https://novationmusic.com/en/keys/launchkey-mini) MIDI keyboard controller and it seemed like an excellent __companion__  for the [Novation Circuit](https://novationmusic.com/en/circuit/circuit) groovebox I already owned.

The Launchkey Mini Mk3 is competitively price, it's from the same maker as the Circuit, and they look very good together: both of them are exactly the same height and are made of the same materials.

My goal was to use both devices side by side, using the Circuit's controls to arrange and manipulate the sound, while using the Launchkey to play the actual notes. That means I don't need to map each and every control of the Circuit into the Launchkey, since I'm using the Launchkey mostly to have a "regular" keyboard to play on (as well as using the arpeggiator functionality), while using the Circuit to control each patch, the actual session and the mixer.


## The Setup
I'm running the most recent firmware on both devices:
- Circuit: v1.8
- Launchkey Mini Mk3: v1.0

There are two ways to connect the devices: (i) using MIDI cables for a hardware-only setup, or (ii) using an intermediary computer as an USB MIDI host.

The Launchkey only has a `MIDI Out` connector for hardware setups, but it appears to also support `MIDI In` when using it through USB.

Make sure that the Circuit has the correct settings, refer to
[this cheatsheet by /u/kikomn](https://www.reddit.com/r/novationcircuit/comments/a9blg4/cheat_sheet_novation_circuit/). Turn on the Circuit holding the `Shift` button to access the settings menu, and save the settings by pressing `Play`.

### Hardware only with MIDI
As MIDI devices have been shrinking in size, a new MIDI plug standard has been developed around a common 1/8" TRS connector (think headphones), this means that in order to connect with _regular_ MIDI devices an adaptor is required. Also, there are 2 variations of this new plug: Type A and Type B. And both look exactly the same.

The Circuit includes 2 TRS-to-DIN breakout adaptors, and being a slightly older device, it uses Type B. The Launchkey Mini does not include any breakout adaptors, but it uses Type A.

This means I was not able to use the 2 adaptors included in the Circuit to connect it to the Launchkey, since they require different types.

In other words, the required chain would be:

```
Circuit MIDI In <-> Type B TRS MIDI adaptor <-> Standard MIDI cable <-> Type A TRS MIDI adaptor <-> Launchkey Mini Mk3 MIDI Out
```

I've already ordered a Type A breakout cable, I'll update this post when I try it.


### Software based (USB Host)
Another option is to use a computer as a MIDI Host to link between different MIDI devices and route their signals to each other.

On macOS Catalina (10.15) I'm using a small application called [MIDIRouter](https://github.com/icaroferre/MIDIRouter). The app has a dependency on the [portmidi library](https://sourceforge.net/projects/portmedia/); it won't run without it, but it won't tell you if you don't have it. If you already have [brew](https://bew.sh), you can install the dependency by typing `brew install portmidi` into your terminal.

MIDIRouter is as simple as it gets. Make sure to keep your computer is awake and the app running, and then just configure it to:

- MIDI In: Launchkey Mini
- MIDI Out: Circuit


## Layouts for Launchkey (Custom Modes)
The Circuit has a very simple MIDI interface:
- Synth 1 is on Channel 1
- Synth 2 is on Channel 2
- Drums are on Channel 10, specifically:
  - Drum 1: 60 (C3)
  - Drum 2: 62 (D3)
  - Drum 3: 64 (E3)
  - Drum 4: 65 (F3)

The Circuit only supports 4 different drum samples, but the Launchkey has 16 pads (2 rows, 8 columns). I repeated each drum 4 times in a mirrored pattern for "better" finger-drumming.

![Custom Mode for Launchkey with Circuit][/images/posts/2020-02-02-novation-circuit-and-launchkey-mini-mk3/components-layout.png]

Other than that, I didn't mess with the pots since I'm not planning on using them on the Launchkey. The Circuit has encoders while the Launchkey has pots, and that makes for a weird mapping. I'm not sure if the Launchkey Mini Mk3 supports linking PGM parameters to the pads, but it'd allow for some sweet configurations.


## General Notes
#### Scales
Remember to change scale mode in the Circuit to chromatic (bottom right) to be able to use the keyboard properly, selecting any other scale will make you keyboard play the closest note in the scale (ie. in a C major scale, pressing the C key on the Launchkey will play a C note as expected, but pressing the C# key will also play a C note). I guess this would make it easier to "improvise" by mashing the keyboard carelessly when using a scale?

#### MIDI Channel Control
To switch between the Synth 1 and Synth 2, you have to change the MIDI channel in the Launchkey, this is done by pressing both the `Shift` and `Transpose` buttons on the Launchkey and then selecting the channel with the pads (channel 1 = synth 1 = top row leftmost pad; channel 2 = synth 2 = top row, second pad left-to-right). I would love it if it'd be possible to program the Launchkey to use the bottom row of the pads to select and display the current MIDI channel, from 1 to 8. PGM parameters?

#### Tempo
If you want to properly use the arp functions in the Launchkey, it must be synced to the Circuit's master tempo.

There are 3 options that I've though of, but I have not tried them all yet. More testing is required and I will update this post onxe I have some results.

1. Use the Launchkey as the tempo master.  Turn off the Circuit's `MIDI Clock Tx` while keeping the `MIDI Clock Rx` turned on. Adjust the tempo in the Launchkey and the Circuit should sync to it. The `Tempo` button in the Circuit should display the current tempo
2. When using the USB Host connectivity, the Launchkey appears to have a `MIDI In` port, which should enable the Circuit to act as a tempo master (`MIDI Clock Tx` on, `MIDI Clock Rx` off).
3. Setup both tempos manually. Turn off both the `MIDI Clock Rx` and `MIDI Clock Tx`on the Circuit's setting to prevent them from being overridden by the Launchkey internal tempo, or viceversa. Good luck.

#### Macro Controls
Macro controls (the 8 encoders in the Circuit) are funky when mapped to the Launchkey's pots. I've never liked mixing encoders (infinite revolutions) with potentiometers (limited turning), so I prefer not to use them at the moment.

#### Record & Play
The record and play buttons on the Launchkey do nothing. You have to use the Circuit's.


#### Pitch Bend and Modulation
I have not been able to use the sustain and modulation touch bands on the Launchkey, it appears that the Circuit does not support pitch and modulations controls at all.


#### Sustain Pedal
I have not tested using a sustain pedal. I probably won't anytime soon, since I would mostly be using the setup for bass lines and arp chords.



## References
- [/u/kikomn Circuit MIDI cheatsheet on reddit](https://www.reddit.com/r/novationcircuit/comments/a9blg4/cheat_sheet_novation_circuit/)
- [/u/jumping-trains reddit comment](https://www.reddit.com/r/novationcircuit/comments/e2j7yl/lauchkey_mini_mk3_with_circuit/f95j5bg/)

