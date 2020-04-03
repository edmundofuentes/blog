---
title: Controlling a Behringer X-Air mixer with a Novation Launchpad via MIDI
tags:
    - ssh
    - yubikey
    - security
    - macos
categories:
    - music
draft: yes
---



Behringer X-Air XR12

Launchpad Mini Mk1: 8x8 (64 pads), 3 color (Green, Orange, Red)

MIDI commands (see link)


MIDI XOSC -> only sends to mixer, no read
a MIDI dump can be triggered , which is aprox 320 bytes

OSC requires full network implementation

SysEx OSC -> network 

Mackie Control (MCU) Protocol


Sample OSC message:
 "/ch/16/mix/07/level -oo" 
 
 For example, channel 14 send to bus 3 fader level at -10 db would be
 OSC: /ch/14/mix/03/level -10

F0 00 20 32 32 2F 63 68 2F 31 34 2F 6D 69 78 2F 30 33 2F 6C 65 76 65 6C 20 2D 31 30 F7


https://community.musictribe.com/t5/Mixing/How-to-read-obtaining-MIDI-OSC-Data-from-XR18/td-p/226409/page/2


For example, channel 14 send to bus 3 fader level at -10 db would be
OSC: /ch/14/mix/03/level -10
F0 00 20 32 32 2F 63 68 2F 31 34 2F 6D 69 78 2F 30 33 2F 6C 65 76 65 6C 20 2D 31 30 F7

https://community.musictribe.com/t5/Recording/MIDI-Control-of-Channel-AUX-sends/m-p/207476/highlight/true#M24273


Certain MIDI equipment can perform more advanced tasks by receiving system-exclusive or "SysEx" commands.



from the manual Xair
Text Based OSC - "SYX" command

Open Sound Control via Sysex
F0 00 20 32 32 TEXT F7

With ‘TEXT’ being OSC strings in hex format, up to 39 kB in length


 
There is also a MIDI Dump command, B0 7F 7F which will echo out all valid CCs with values as I understand.


References

Behringer X-Air Series Manual [English]
https://media63.musictribe.com/media/PLM/data/docs/P0AWZ/X-AIR-Series_M_EN.pdf

MIDI Control of AUX Channels 
https://community.musictribe.com/t5/Recording/MIDI-Control-of-Channel-AUX-sends/td-p/207475