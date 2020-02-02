Notes about using the Circuit with the Launchkey Mini Mk3 keyboard controller

Hey there,

The Launchkey Mini Mk3 is competitively price, it's from the same brand as the Circuit, and it looks very good together (both of them are actually exactly the same height)

My goal was to use both devices side by side, using the Circuit's controls to arrange and manipulate the sound, and using the Launchkey to play. That means I don't need to map each and every control of the Circuit to the Launchkey, that'd make no sense.  For example, I'm using the encoders in the Circuit to control each patch, using the play and record buttons on the Circuit. I'm using the Launchkey mostly to have a "regular" keyboard to play on, as well as using the arpeggiator functions in the Launchkey.

I wrote this short guide as my notes-to-self, and I thought it may be helpful for somebody else too.

The Setup
I'm running the most recent firmware on both devices: Circuit v1.8, Launchkey Mini Mk3 v1.0.1.

Ideally


The Circuit includes two Type B adaptors, the Launchkey Mini does not include any.

Circuit's MIDI IN / OUT connectors require a TRS to DIN breakout connector, this is "Type B".

Launchkey Mini Mk3 also has a MIDI OUT TRS connector, it's physically the same shape and size, but internally it is wired as a "Type A".

In other words, 

Ciruit - Type B TRS MIDI adaptor - Standard MIDI cable - Type A TRS MIDI adaptor - Launchkey Mini Mk3


I have not been able to The sustain and modulation touch surface bands do not work at all.


For now, I'm using the MIDIRouter app on macOS Catalina (in order to use it, you must install `portmidi` first using brew: `brew install portmidi`)

Layouts

Notes:
- Remember to change scale mode in the Circuit to chromatic (bottom right) to be able to use the keyboard properly, selecting any other scale will make you keyboard play the closest note in the scale (ex. in C major scale, pressing the C key will play a C note as expected, but pressing the C# key will also play a C note). I guess this would make it easier to "improvise" by mashing the keyboard carelessly?
- To switch between the Synth 1 and Synth 2, you have to change the MIDI channel in the Launchkey, this is done by pressing both the Shift and Transpose buttons on the Launchkey and then selecting the channel with the pads (channel 1 = synt 1 = top row leftmost pad; channel 2 = synth 2 = top row, second pad left-to-right). I would love it if it'd be possible to program the Launchkey to use the bottom row of the pads to select and display the current MIDI channel, from 1 to 8. Any ideas?
- Macro controls (the 8 encoders in the Circuit) are funky when mapped to the Launchkey's pots, so I prefer not to use them at the moment.
- The record and play buttons on the Launchkey do nothing.
- I have not tested using a sustain pedal since I would mostly be using the setup for bass lines and arp chords.
- Tempo: If you want to use the arp functions in the __ the Circuit MIDI settings should be ON for Clock sync ___ 


Let me know if you guys have any questions or if you've been able to solve any of the issues I've had.
Cheers!