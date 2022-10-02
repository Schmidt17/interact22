# interact

A system for interactive control, targeted for musical or other performances.

In a musical group performance, musicians act and react to each other's actions 
as they are performing. This creates an experience which is unique to the
people involved and the setting they are in. Everyone hears and modifies the
acoustic product of everyone's actions as they are producing it, which can
lead to results that can hardly be planned or foreseen, and that transport
the unique fingerprint of the group and the moment.

The goal of the system designed here is to expand that process to the 
parameters of a performance that are not accessible to each individual.
Examples could involve audio mixing or audio/MIDI effects.

To make these parameters tangible in a musical way, two aspects need to be
realized:

- An interface for physically controlling the parameters
- A form of feedback about the current state of the parameters

Both those aspects are adressed by the system here, which we call **interact**.

## General architecture

The components of **interact** can be split in three groups:

*Controllers*, which allow setting parameters and observing their state.
Controllers can be digital user interfaces like websites or apps,
or hardware controllers that connect with the backend.

The *backend*, which is essentially a message relay with additional 
tools for persistence and configuration.

*Actors* that directly set the parameters, e.g. a digital audio workstation,
a mixer or other components that connect with the backend.
