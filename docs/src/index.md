# Bijou64.jl

Bijou64.jl is a Julia implementation of the bijou64 variable-length integer encoding.

See the [bijou64 specification](https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md) for details.

For commentary on the motivations and performance outcomes, read the [blog post](https://www.inkandswitch.com/tangents/bijou64/) announcing the encoding.

## Installation

Bijou64.jl can be installed using `Pkg`.

```julia
pkg> add https://github.com/KyleSJohnston/Bijou64.jl
```

## Example Usage

```julia
julia> using Bijou64

julia> Bijou64.encode(UInt64(67_000))
4-element Vector{UInt8}:
 0xfa
 0x00
 0x03
 0xc0

julia> Bijou64.decode(UInt64, [0xfa, 0x00, 0x03, 0xc0])
1-element Vector{UInt64}:
 0x00000000000105b8
```

## API

```@index
```

```@autodocs
Modules = [Bijou64]
Private = false
Order   = [:type, :module]
```
