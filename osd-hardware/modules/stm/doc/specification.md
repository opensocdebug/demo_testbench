# Introduction

This document specifies the implementation of the Software Trace
Module. The purpose of this module is to allow software running on a
processor core to emit trace events. The trace events tuples of and
identifier `ID` and a `value`. The trace events are further annotated
with a timestamp. By that the developer can use software tracing for a
variety of purposes, for example:

- Annotate the source code to perform timing measurements

- Correlate software execution of different cores

- Simply as a replacement for printf-debugging

- Transfer small data amounts between the software and a debug tool

Software tracing is minimally intrusive, meaning it does only consume
a few processor cycles. Hence it generally allows to keep a minimal
set of trace debug information in productive code.

## License

This work is licensed under the Creative Commons
Attribution-ShareAlike 4.0 International License. To view a copy of
this license, visit
[http://creativecommons.org/licenses/by-sa/4.0/](http://creativecommons.org/licenses/by-sa/4.0/)
or send a letter to Creative Commons, PO Box 1866, Mountain View, CA
94042, USA.

You are free to share and adapt this work for any purpose as long as
you follow the following terms: (i) Attribution: You must give
appropriate credit and indicate if changes were made, (ii) ShareAlike:
If you modify or derive from this work, you must distribute it under
the same license as the original.

## Authors

Stefan Wallentowitz

Fill in your name here!

# Core Interface: Software Trace Port

The software trace port is a simple data port with an `enable`
signal. There is no backpressure as the debug infrastructure is not
supposed to influence the processor execution.

The interface is defined as:

 Name     | Width       | Description
 -------- | ----------- | -----------
 `id`     | 16          | Trace identifier
 `value`  | `REG_WIDTH` | Trace value, width of CPU general purpose registers
 `enable` | 1           | Trace an event this cycle

# Memory Map

The basic memory map of control and status applies. Beside this there
are currently no registers available.

# Trace Primitives

Generally, the trace primitives are divided in a groups:

 Identifiers         | Group | Description
 ------------------- | ----- | -----------
 `0x0000`            | N/A   | Not used
 `0x0001` - `0x3fff` | USER  | User-defined trace events
 `0x4000` - `0x7fff` | COM   | Commonly defined trace events
 `0x8000` - `0xbfff` | N/A   | Reserved
 `0xc000` - `0xffff` | SYS   | System-generated trace events

The implementation of all trace events is optional, both for software
and for hardware.

## User-defined trace events (USER)

Trace events from this group are generated from software
execution. There are many possibilities to implement them in hardware,
but from the ABI there are generally two data items that a software
writes to emit a trace event: first it writes the `value` and then it
writes the `id`.

As those are two memory accesses in two distinct operations the
following properties must hold:

 - Sequential consistency: The write to the second data item must
   occur after the first data item. This property is usually enforced
   with memory fences.

 - Atomicity: The first data item must not be changed in multithreaded
   systems or by interrupt processing in general.

For more details see the section *Trace Generation* in the following.

## Commonly defined trace events (COM)

Those are trace events identical to the user-defined trace events, but
that have a commonly defined semantic meaning. Their semantic meaning
is therefore still transparent to the hardware module, but common to
all platforms. This eases implementation of trace debugger tools.

You can find a list of events at the end of this specification.

## System-generated trace events (SYS)

This group of trace events are generated by the hardware or by the
operating/runtime system. For the latter the same method as
user-defined trace events is used. For hardware-generated events the
method of emitting the trace event is core-specific and examples are
described in the the section *Trace Generation*.

# Trace generation

The method of emitting a trace event depends on the
micro-architecture. Examples for existing processor core architectures
are given in the following.

## Software Trace Port: OpenRISC

In OpenRISC an interesting property of the instruction set is used:
The no-operation `l.nop` has a parameter `K` of 16 bit width. The
specification defines this parameter to be used for simulation
purposes, and it is here used to emit the trace value.

We use this operation for the trace identifier. As the compiler emits
`l.nop 0x0`, the user-defined value of `0x0000` is not available in
this specification.

The trace value is defined to be written to the general purpose
register `r3` with the properties described before. As a general
purpose register is restored after interrupts, the atomicity property
holds. Finally, the register `r3` is the first function parameter
register in the ABI which eases efficient implementation of library
functions for trace events.

In the hardware implementation the writeback stage must be observed
and whenever a write to register `r3` is observed, the same value is
stored into the register `value`. When completion of an `l.nop`
operation is observed, the opeand `K` (if not equal to 0) and the
`value` are emitted on the trace port for one cycle.

Finally, the following extension is required to support the trace
event `THREAD_SWITCH`: All writes to register `r10` must be tracked
and if a value is written, the trace event is emitted. The register is
historically reserved and in the Linux port used as thread-local
storage (TLS), which is unique for concurrently executed threads.

## Software Trace Port: RISC-V

In RISC-V an additional control register is added to emit a trace
event (non-standard for the moment). A write to this register triggers
the emission of the trace event for one cycle.

Beside this, the general purpose register `x18` (`a0`) is tracked for
updates as the trace event value, identical to the reasoning for
OpenRISC.

Finally the register `x15` (`tp`) may also be tracked and a
`THREAD_SWICH` trace event is emitted on updates to the register.

## Software Trace Port: Other cores

The method described for the RISC-V microarchitecture should be
applicable to a variety of RISC cores.

## Software Trace Port: Out-of-Order

With out-of-order cores it is important to track the accesses to the
two data items properly, which can be enforced by a memory fence.

In an out-of-order implementation the software trace port may be
implemented more efficiently at stages where the trace event may still
be canceled. If that is the case, the software trace port should hold
back the value until it can be safely emitted or aborted beforehand.

# List of Trace events

## Commonly defined (COM group)

 Identifier | Name          | Description
 ---------- | ------------- | -----------
 `0x4000`   | `THREAD_NAME` | Emit a thread name, emitted repeatedly

## System-generated (SYS group)

 Identifier | Name            | Description
 ---------- | --------------- | ----------- 
 `0x8000`   | `THREAD_SWITCH` | Unique value of the scheduled thread
