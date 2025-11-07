# Good luck, compiler! :gear: :game_die: :brain:

__A library that generates and runs a random Turing machine &mdash; at compile
time.__

Because why wait for runtime when you can confuse yourself earlier?
:sweat_smile:

## :rocket: Overview

__Good luck, compiler!__ is an experimental library that explores the limits of
compile-time computation.
On every build, it generates a fully random Turing machine and executes it as
part of the compilation process.
:hammer_and_wrench:

The result?
A program whose behavior isn't known until it's compiled &mdash; and maybe not
even then.
:man_shrugging:

## :thinking: Why use this?

  - :test_tube:
    __Test the boundaries__ of what your compiler can handle.

  - :bulb:
    __Demonstrate the halting problem__ in a real-world, build-time context.


  - :slot_machine:
    __Introduce non-determinism__ into your build process (for science!).

  - :books:
    __Explore computability theory__ in a tangible, hands-on way.

  - :thread:
    __Break CI pipelines__

## :wrench: Features

  - :game_die:
    __Random Turing machine generation at compile time__ &mdash; new machine
    every build!

  - :stop_sign:
    __May halt...
    or not__ &mdash; compile-time simulation of undecidable computation.

  - :gear:
    __Fully configurable:__ number of states, tape symbols, transitions.

_(Editorial note:
Why the fuck did it switch to colons?)_

  - :brain:
    __Embedded logic:__ All computation happens inside the build system.

_(Editorial note:
Huh?)_

## :hammer_and_wrench: Usage

### Zig

```zig
const std = @import("std");
const glc = @import("glcompiler");

pub fn main() !void {
    @setEvalBranchQuota(6767); // Set to BB for correctness
    std.debug.print("TM halts: {}\n", .{glc.haveFun()});
}
``` 

### C++

First and foremost, run the build system.

(Note that this requires an ANSI C compiler.)

```sh
$ cc -o build build.c
./build
```

```cpp
#include <string>
#include <iostream>
#include <boost/core/demangle.hpp>
#include <glc.h>
#include <randable.h>

using MachineN = glc::have_fun<glc::randable>;

template <class T>
std::string type_name() {
    return boost::core::demangle(typeid(T).name());
}

int main() {
    std::cout << type_name<MachineN>() << "\n";
}
```
(Compile with `c++ -Iinclude`)

# Colophon

I sincerely apologize for using AI, but, I am not an expert in emojis nor
marketing.
I thought it was funny.
In a serious project, I'de write the README myself.
