"""
    ColorFilterArray{D} <: AbstractMatrix{UInt8}

Supertype for different kinds of color filter arrays of linear size `D`.
The channels are enumerated by `UInt8` data, with `0x1`, `0x2`, and `0x3` corresponding to red,
green, and blue channels.
In principle, custom types can use all possible `UInt8` values to refer to up to 128 different
channels per sensor.

# Indexing

When linearly indexed, the valid indices of a `ColorFilterArray{D}` range from 1 to `D^2`.
Multidimensional indices are treated as periodic, and will be remapped with `mod1`.
This is done intentionally, because a multidimensional index of an image can always be mapped back
to the color filter array without any extra information, but a linear index cannot without more
information about the size of the image.

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

function Base.size(::Type{<:ColorFilterArray{D}}) where D
    D isa Integer || throw(TypeError(:size, Integer, typeof(D)))
    return tuple(Int(D), Int(D))
end

Base.size(cfa::ColorFilterArray) = size(typeof(cfa))
Base.IndexStyle(::Type{<:ColorFilterArray}) = IndexLinear()

# Define these with respect to the type
Base.eachindex(::IndexLinear, ::ColorFilterArray{D}) where D = Base.OneTo(D^2)
Base.eachindex(::IndexCartesian, ::ColorFilterArray{D}) where D = CartesianIndices((D, D))

# Don't check bounds when using Cartesian indexing because the array is periodic
Base.checkbounds(::Type{Bool}, ::ColorFilterArray, i1, i2) = true

function Base.getindex(cfa::ColorFilterArray{D}, inds::Vararg{Int,2}) where D
    return @inbounds getindex(cfa, LinearIndices(cfa)[mod1.(inds, D)...])
end

Base.getindex(cfa::ColorFilterArray, inds::Vararg{Int}) = throw(BoundsError(cfa, inds))

function Base.getindex(cfa::ColorFilterArray, i::Union{Integer,CartesianIndex}...)
    return getindex(cfa, to_indices(cfa, i)...)
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

#---Generic color filter array type----------------------------------------------------------------#
"""
    GenericCFA{D,M<:AbstractMatrix{UInt8}} <: ColorFilterArray{D}

Stores a color filter array of linear size `D` in a matrix of type `M`.
This function can be used to represent color filter arrays that don't have a dedicated type.
"""
struct GenericCFA{D,M<:AbstractMatrix{UInt8}} <: ColorFilterArray{D}
    matrix::M
    function GenericCFA{D,M}(matrix) where {D,M}
        sz = size(matrix)
        sz === (D,D) || throw(
            DimensionMismatch("matrix must have size ($D, $D), got $sz")
        )
        return new(matrix)
    end
end

GenericCFA{D}(matrix::M) where {D,M<:AbstractMatrix{UInt8}} = GenericCFA{D,M}(matrix)
GenericCFA{D}(matrix::AbstractMatrix{<:Integer}) where D = GenericCFA{D}(convert.(UInt8, matrix))

@propagate_inbounds Base.getindex(cfa::GenericCFA, i::Int) = cfa.matrix[i]

function Base.reverse!(cfa::GenericCFA; dims = :)
    reverse!(cfa.matrix; dims)
    return cfa
end

Base.reverse(cfa::T; dims = :) where T<:GenericCFA = T(reverse(cfa.matrix; dims))
Base.permutedims(cfa::T) where T<:GenericCFA = T(permutedims(cfa.matrix))

function Base.circshift!(cfa::GenericCFA, shifts)
    circshift!(cfa, shifts)
    return cfa
end

function Base.circshift(cfa::T, shifts::NTuple{N,Integer}) where {N,T<:GenericCFA}
    return T(circshift(cfa.matrix, shifts))
end
