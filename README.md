8cc.vim: Pure Vim script C Compiler
===================================

This is a Vim script port of [8cc](https://github.com/rui314/8cc) built on [ELVM](https://github.com/shinh/elvm).
In other words, this is a complete C compiler written in Vim script.

[8cc](https://github.com/rui314/8cc) is a nicely-written small C compiler for x86_64 Linux. It's C11-aware and self-hosted.

[ELVM](https://github.com/shinh/elvm) is a **E**so **L**ang **V**irtual **M**achine.
ELVM customizes 8cc to emit its own intermediate representation, EIR as frontend.
ELVM compiles C code into EIR via the frontend.  And then translates EIR into various targets (Python, Ruby, C,
BrainFxxk, Piet, Befunge, Emacs Lisp, ...) in backend. The architecture resembles LLVM.
[This presentation](http://shinh.skr.jp/slide/elvm/000.html) is a good stuff to know ELVM architecture further (though in Japanese).

ELVM can compile itself into various targets.
So I added a new 'Vim script' backend and use it to translate C code of 8cc into Vim script.

Now 8cc.vim is written in pure Vim script. 8cc.vim consists of frontend (customized 8cc) and backend (ELC).
It can compile C code into Vim script. And of course Vim can evaluate the generated Vim script code.

Note that this is a toy project. 8cc.vim is much much slower.
It takes 824 (frontend: 430 + backend: 396) seconds to compile the simplest `putchar()` program
on MacBook Pro Early 2015 (2.7 GHz Intel Core i5). But actually it works!

As VM runs on Vim script, 8cc.vim works on Linux, OS X and (hopefully) Windows.

# Installation

Please clone this repository and `:packadd` (please see `:help pack-add`).

Or please use your favorite plugin manager ([vim-plug](https://github.com/junegunn/vim-plug),
[dein.vim](https://github.com/Shougo/dein.vim) and so on).

# Usage

- Commands
  - `:EccCompile`
  - `:EccRun`
- Functions
  - `eightcc#compile()`
  - `eightcc#run()`

## Compile C Code

Prepare your C code in the current buffer. Following is a 'Hello world' example.

```c
int putchar(int x);

int main() {
  const char* p = "Hello, world!\n";
  for (; *p; p++)
    putchar(*p);
  return 0;
}
```

Then execute `:EccCompile` command. Note that you can use several options such as `--verbose` for this.
Please see `:EccCompile --help` for more detail.

It takes a long time 20 minutes or more.  Let's take a rest and get some :coffee:.

As the result, new buffer is opened with Vim script code which was compiled from C code. Load it by
`:w putchar.vim` and `:source putchar.vim`.

Finally, execute below Vim script code by your hand.  The compiled code is run on VM on Vim script.
The `SetupVM()` function creates a VM instance.

```
:let vm = SetupVM()
:call vm.run()
```

![result screen shot]()

If you want to see only the result of running Vim script, you can use `:EccRun` to skip above process.

Corresponding to `:EccCompile` and `:EccRun`, you can use `eightcc#compile()` and `eightcc#run()` functions.
They can take one dictionary for execution options.

# License

MIT License

Copyright (c) 2016 rhysd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
