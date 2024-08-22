# EXA Color

𝔼𝕏tr𝔸 𝔼li𝕏ir 𝔸dditions (𝔼𝕏𝔸)

EXA project index: [exa](https://github.com/red-jade/exa)

Utilities for colors: 1-4 components, float/byte data types,
color space conversions and named colors (CSS).

Module path: `Exa.Color`

## Naming Convention

Modules are named with:
- digit for the number of components: 1, 2, 3, 4
- letter (lowercase) for the data type: b (byte), f (float)

For example, `col3f` is a 3-component color using unit float values, e.g. RGB.

## Design

The design prefers plain (untagged) tuples
for compact size and efficient O(1) access time (contiguous in memory).

Scalar 1-component colors are simple atomic types.
Multi-component colors use tuples.

Colors used for images have a separate pixel type 
to label the components.
The pixel format tag is not embedded in every color tuple.

CSS colors are loaded from a text file on demand.
The look-up table is stored in the process dictionary.
Every process that accesses CSS colors will have a copy.

## Features

- Colors: 1,3,4 byte,float
- Color models: RGB, HSL
- Color maps: index => col3b
- Named CSS colors
- Pixels and components
- Conversion utilities: byte,float

## Building

To bootstrap an `exa_xxx` library build, 
you must run `mix deps.get` twice.

## EXA License

EXA source code is released under the MIT license.

EXA code and documentation are:<br>
Copyright (c) 2024 Mike French
