"""
    ColorFilterArray{D} <: AbstractMatrix{UInt8}

Supertype for different kinds of color filter arrays of linear size `D`.
The channels are enumerated by `UInt8` data, with `0x1`, `0x2`, and `0x3` corresponding to red,
green, and blue channels.
In principle, custom types can use all possible `UInt8` values to refer to up to 128 different
channels per sensor.

# Extended Help

## Implementing a custom ColorFilterArray type

The default implentation of certain array operations that should return a `ColorFilterArray`
returns a `Matrix{UInt8}` instead.
These functions include:
  * `Base.reverse`
  * `Base.permutedims`
  * `Base.circshift`
When implementing a `ColorFilterArray` type, these output types of these functions should match
the input type.
"""
abstract type ColorFilterArray{D} <: AbstractMatrix{UInt8}
end

Base.size(::ColorFilterArray{D}) where D = tuple(D,D)
Base.IndexStyle(::Type{<:ColorFilterArray}) = IndexLinear()

function Base.getindex(cfa::ColorFilterArray{D}, i1::Int, i2::Int) where D
    return @inbounds getindex(cfa, LinearIndices(cfa)[mod1(i1, D), mod1(i2, D)])
end

"""
    _channel_to_uint8(c::Char)
    _channel_to_uint8(s::AbstractString)

Converts a character to a `UInt8` representing the relevant color channel:
  * `'R'` and `'r'` become `0x1`.
  * `'G'` and `'g'` become `0x2`.
  * `'B'` and `'b'` become `0x3`.
  * Other inputs become `0x0`.

For a string argument, the first character is used to make this determination.
"""
function _channel_to_uint8(c::Char)
    c in ('r', 'R') && return 0b01
    c in ('g', 'G') && return 0b10
    c in ('b', 'B') && return 0b11
    return 0b00
end

_channel_to_uint8(s::AbstractString) = _channel_to_uint8(first(s))
