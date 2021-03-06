# Yatima Haskell Prototype

This was an early version of Yatima which used a Haskell Higher-Order-Abstract-Syntax representation for reduction and IPFS for content-addressing. The new implementation in Rust at https://github.com/yatima-inc/yatima, uses [Bottom-Up Beta-Reduction paper](https://www.ccs.neu.edu/home/shivers/papers/bubs.pdf), and a new content-addressing schema called Hashspace.

# Yatima: A programming language for the decentralized web

---

> In one sense, the Truth Mines were just another indexscape. Hundreds of
> thousands of specialized selections of the library's contents were accessible
> in similar ways--and Yatima had climbed the Evolutionary Tree, hopscotched the
> Periodic Table, walked the avenue-like Timelines for the histories of
> fleshers, gleisners, and citizens. Half a megatau before, ve'd swum through
> the Eukaryotic Cell; every protein, every nucleotide, even carbohydrate
> drifting through the cytoplasm had broadcast gestalt tags with references to
> everything the library had to say about the molecule in question.
>
> In the Truth Mines, though, the tags weren't just references; they included
> complete statements of the particular definitions, axioms, or theorems the
> objects represented. The Mines were self-contained: every mathematical result
> that fleshers and their descendants had ever proven was on display in its
> entirety. The library's exegesis was helpful-but the truths themselves were
> all here.
>
> *Diaspora*, Greg Egan

---

<div align="center">
<img src="/source/images/yatima_logo.svg"  width="400" height="400">
</div>

---

Yatima is a pure functional programming language with the following features:

- **Content-Addressing** powers reproducible builds, and peer-to-peer
  package management over IPFS. A Yatima content-address represents an
  _immutable_ program and all its dependencies. That means if someones shares an
  address with you, you can perfectly replicate their computation (and in
  principle even their computing environment!). Since the program is immutable,
  the way it runs the first time is the way it runs everytime.
- **First-class types**. This lets you the programmer to tell the compiler what
  you _intend_ to do in your program. Then, like a helpful robot assistant, the
  compiler will check to make sure that what you're _actually doing_ matches
  those expressed intentions. Type-driven programming lets the compiler act as
  your "correctness exocortex", i.e. a cognitive augmentation that helps you
  catch your mistakes.
- **Linear, affine and erased types** give you fine-grained control over
  resource usage during execution. Substructural types allow you to get the
  memory safety benefits of using a high-level language, while also allowing you
  to work "close to the metal" when you want to.
- **Type-safe dependent metaprogramming** lets Yatima have the flexibility and
  extensibility of a dynamically-typed language, without sacrificing the safety
  of static-typing.

## Instructions

0. Install The Haskell Tool Stack. Instructions here: https://docs.haskellstack.org/en/stable/README/

   You'll also need IPFS. You can install IPFS through many different package
   managers, or by downloading a binary directly:
   https://docs.ipfs.io/install/command-line/.

   For example, with [the Nix package manager](https://nixos.org/download.html):

   ```
   $ nix-env -iA nixpkgs.ipfs
   ```

   Then, run start the ipfs daemon in the background with

   ```
   $ ipfs daemon &
   ```

1. Clone this repository, `cd` into it and `stack install`. (This may take a
   while if you've never used stack before).

2. [Clone the Introit standard libary](https://asciinema.org/a/372665) over IPFS with `yatima clone introit /ipns/introit.yatima.io` to [get the standard library]) (you can also use Git with `git clone https://gitlab.com/yatima/introit`).

3. [Typecheck the standard library](https://asciinema.org/a/N8HP32Bk7OMaOHw9zxTOaAkwN) with `yatima check /ipns/introit.yatima.io`
   (or `yatima check introit/Introit.ya`)

4. [Enter a repl](https://asciinema.org/a/372661) with `yatima repl`.

5. [Write a HelloWorld package](https://asciinema.org/a/372666) and run it wit `yatima run HelloWorld.ya`

6. [Pin your package to IPFS](https://asciinema.org/a/372667)

## Motivation

We're still in the early days of the Computing Revolution. The first
general-purpose digital computers were only switched on about 75 years ago.
The living memory of your parents and grandparents extends into the past
*before* computers. These machines are shockingly new, and as a species we
really have no idea what they're for yet. We're in the middle of an epochal
transformation whose nearest precedent is the invention of *writing*.
There are a lot of prognostications of what that means for our future; lots 
of different, and sometimes contradictory, visions of how computing is going 
to continue to shape our minds, our bodies, and our relationships with one 
another.

Yatima, as a project, has an opinionated view of that future. We think computing
should belong to individual users rather than corporations or states. A
programming language is an empowering medium of *individual* expression, 
where the user encounters, and extends their mind through, a computing machine.
We believe "Programmer" shouldn't be a job description, anymore than "scribe" 
is a job description in a world with near-universal literacy. Computing belongs 
to everyone, and computer programming should therefore be maximally accesibile 
to everyone.

Currently, it's not: There are about 5 billion internet users worldwide, but
only an estimated 25 million software developers. That's a "Programming Literacy
rate" of less than 1%. Furthermore, that population is not demographically
representative. It skews heavily toward men, the Global North, and those from
privileged socioeconomic or ethnic backgrounds. This is a disgrace.
It is if we live in some absurd dystopia where only people with green eyes 
play music.

A new programming language isn't going to be some panacea that solves that
problem on its own, but there are some ways in a programming language can help:

1. Build a simple, but powerful programming language. Yatima's
   core logic is under 500 lines of code, but is incredibly expressive in its
   type system, runtime and syntax. We want to reduce the language's conceptual
   overhead, without hindering the language learner's future growth and power.

2. Make explicit in the language the connection between computing and
   mathematics. These two seemingly separate fields are actually, in essence,
   the same: All proofs are programs, all programs are proofs. A student
   doing math homework *is* programming, even if they don't conceptualize at
   such.

   Many people dislike math due to the tedium of manual computation and the
   unclear relevance of the results. And many people dislike programming because
   the concrete mechanics often seem arbitrary and frustrating. These are are
   complementary complaints. Math is more fun when you have a computer to take
   care of the detail-work. And computing is much easier when you have a clear
   notion of the theory of what you're doing.

3. Be portable in execution. Run locally, in the browser, on mobile, in a 
   distributed process. People shouldn't have to worry about the details of 
   *where* they want to do something, only *what* they want to do.

4. Be portable in semantics. Pure semantics and reproducible builds let people
   focus on the actual content of their programs rather than the scut-work of
   configuring infrastructure.

5. Integrate with decentralized technologies to remove, as much as possible,
   social barriers and frictions. Having centralized services like
   most modern package managers raises the question "Who controls the package server?" 
   The famous [leftpad incident](https://qz.com/646467/how-one-programmer-broke-the-internet-by-deleting-a-tiny-piece-of-code/from)
   is commonly presented as a build system issue (which it absolutely is), but
   less frequently discussed is that what precipitated the incident was how the
   `npm` administrators transfered ownership of a package from an individual
   developer without their consent to a large company.

6. Have a clear code of conduct to combat the endemic toxicity of contemporary
   programming culture. Some might find this controverisial, but it shouldn't be.
   Computing is a social and cultural project as much as it is a technical one.
   Cultures which perpetuate cycles of trauma are less successful in the long
   run than ones which do not.

The future we want to build is one where billions of people use, understand and
love their mathematical computing machines, as natural extensions of
themselves. A future where users have autonomy and privacy over their own
systems and their own data. A future where reliable, type-checked,
formally-verified software is the norm, so you can rely on software engineering
with the same quotidian confidence you have for civil engineering whenever you 
drive your car over a bridge.

## License

```
The Yatima Programming Language

Copyright (C) 2020 Yatima Inc.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
```

