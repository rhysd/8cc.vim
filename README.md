8cc.vim: Pure Vim script C Compiler
===================================

This is a Vim script port of [8cc](https://github.com/rui314/8cc) built on [ELVM](https://github.com/shinh/elvm).
In other words, this is a complete C compiler written in Vim script.

[8cc](https://github.com/rui314/8cc) is a nicely-written small C compiler for x86. It's C11-aware and self-hosted.

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
It takes 824 (frontend: 430 + backend: 396) seconds to compile the simplest `putchar()` program.
But actually it works!

## Usage

TODO

## License

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
