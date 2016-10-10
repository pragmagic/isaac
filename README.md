# isaac

Nim implementation of [ISAAC](http://www.burtleburtle.net/bob/rand/isaacafa.html) -
a cryptographically secure PRNG.

API:
```nim
type IsaacGenerator* = ref object

proc newIsaacGenerator*(seed: array[256, uint32]): IsaacGenerator
  ## Initializes and returns ISAAC PRNG instance.
  ## Make sure the seed is an array of *true random values* obtained from a
  ## source like urandom. Otherwise, security of the algorithm is compromised.

proc nextU32*(generator: IsaacGenerator): uint32
  ## Returns the next generated 32-bit value

proc randomUint32*(generator: IsaacGenerator): uint32
  ## Alias for ``nextU32``. Added for compatibility with nim-random library.
```

## License
This library is licensed under the MIT license.
Read [LICENSE](https://github.com/pragmagic/isaac/blob/master/LICENSE) file for details.

Copyright (c) 2016 Xored Software, Inc.