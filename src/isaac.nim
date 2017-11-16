# Copyright 2016 Xored Software, Inc.

# A translation of C implementation: http://burtleburtle.net/bob/c/readable.c
# It has been tested to produce the same results with zero seed

const isaacStateSize = 256'u32

type
  IsaacGenerator* = ref object
    state: array[isaacStateSize, uint32]
    results: array[isaacStateSize, uint32]
    aa,bb,cc: uint32
    nextIdx: uint32

template mix(a, b, c, d, e, f, g, h: uint32) =
  a = a xor (b shl 11)
  d += a
  b += c
  b = b xor (c shr 2)
  e += b
  c += d
  c = c xor (d shl 8)
  f += c
  d += e
  d = d xor (e shr 16)
  g += d
  e += f
  e = e xor (f shl 10)
  h += e
  f += g
  f = f xor (g shr 4)
  a += f
  g += h
  g = g xor (h shl 8)
  b += g
  h += a
  h = h xor (a shr 9)
  c += h
  a += b

proc regen(gen: IsaacGenerator) =
  var aa = gen.aa
  var bb = gen.bb
  var cc = gen.cc

  inc cc # cc just gets incremented once per 256 results
  bb = bb + cc # then combined with bb

  for i in 0'u32..<isaacStateSize:
    let x = gen.state[i]
    case (i and 3):
    of 0: aa = aa xor (aa shl 13)
    of 1: aa = aa xor (aa shr 6)
    of 2: aa = aa xor (aa shl 2)
    of 3: aa = aa xor (aa shr 16)
    else: discard
    aa = gen.state[(i + isaacStateSize div 2) mod isaacStateSize] + aa
    let y = gen.state[(x shr 2) mod isaacStateSize] + aa + bb
    gen.state[i] = y
    bb = gen.state[(y shr 10) mod isaacStateSize] + x
    gen.results[i] = bb

  gen.aa = aa
  gen.bb = bb
  gen.cc = cc
  gen.nextIdx = 0

template initPass(seed, result: array[isaacStateSize, uint32];
                  a, b, c, d, e, f, g, h: uint32) =
  for i in countup(0'u32, isaacStateSize - 1, 8):
    a += seed[i]
    b += seed[i + 1]
    c += seed[i + 2]
    d += seed[i + 3]
    e += seed[i + 4]
    f += seed[i + 5]
    g += seed[i + 6]
    h += seed[i + 7]
    mix(a, b, c, d, e, f, g, h)
    result[i] = a
    result[i + 1] = b
    result[i + 2] = c
    result[i + 3] = d
    result[i + 4] = e
    result[i + 5] = f
    result[i + 6] = g
    result[i + 7] = h

proc newIsaacGenerator*(seed: array[isaacStateSize, uint32]): IsaacGenerator =
  ## Initializes and returns ISAAC PRNG instance.
  ## Make sure the seed is an array of *true random values* obtained from a
  ## source like *urandom*. Otherwise, security of the algorithm is compromised.
  new(result)
  result.nextIdx = isaacStateSize

  var a,b,c,d,e,f,g,h = 0x9e3779b9'u32
  for i in 0..<4:
    mix(a,b,c,d,e,f,g,h)
  initPass(seed, result.state, a, b, c, d, e, f, g, h)
  # do a second pass to make all of the seed affect all of state
  initPass(result.state, result.state, a, b, c, d, e, f, g, h)

proc nextU32*(generator: IsaacGenerator): uint32 =
  ## Returns the next generated 32-bit value
  if generator.nextIdx == isaacStateSize:
    generator.regen()
  result = generator.results[generator.nextIdx]
  inc generator.nextIdx

proc randomUint32*(generator: IsaacGenerator): uint32 {.inline.} =
  ## Alias for ``nextU32``. Added for compatibility with nim-random library.
  result = generator.nextU32()
