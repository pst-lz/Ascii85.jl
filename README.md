# Ascii85.jl

[![Build status (Github Actions)](https://github.com/pst-lz/Ascii85.jl/workflows/CI/badge.svg)](https://github.com/pst-lz/Ascii85.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://pst-lz.github.io/Ascii85.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://pst-lz.github.io/Ascii85.jl/dev)

ASCII85 in Julia

Encode and decoce ASCII85 (Adobe version) in Julia.

ascii85enc!(in::IO, out::IO):
  in: an IO with binary data,
  out: an IO for the ASCII85
  
ascii85enc(inarr::Array{UInt8}):
  encodes binary data from a Array{UInt8} to a String
  
ascii85dec!(in::IO, out::IO):
  in: an IO with the ASCII85,
  out: an IO for the binary data
 
ascii85dec(in::Array{UInt8}):
  decodes data from a Array{UInt8} to a Array{UInt8}
 
ascii85dec(in::String):
  decodes data from a String to a Array{UInt8}
