#---Bayer color filter arrays----------------------------------------------------------------------#
"""
    _bayer_check(i::UInt8)

Checks that the raw input bits for a Bayer matrix pass simple sanity checking:
  * The matrix has the correct symmetry
  * The matrix has three unique colors
"""
function _bayer_check(i::UInt8)
    # Check that there is a uniform color across one diagonal
    i1 = (i & 0b00000011) >> 0x0
    i2 = (i & 0b00001100) >> 0x2
    i3 = (i & 0b00110000) >> 0x4
    i4 = (i & 0b11000000) >> 0x6
    (i1 === i4 || i3 === i2) || error("the input does not have p4m symmetry.")
    # Check that all colors are represented
    length(unique((i1, i2, i3, i4))) === 3 || error("the input does not represent all colors.")
    return i
end

"""
    BayerCFA <: ColorFilterArray{2}

Represents a Bayer or Bayer-like color filter array in a particular orientation.

The traditional Bayer matrix consists of diagonals of green pixels combined with diagonals of
alternating red and blue pixels. This type supports all other possible arrangements of color 
filters in a 2×2 block of pixels.

The Bayer matrix has the symmetry of
[the wallpaper group p4m](https://en.wikipedia.org/wiki/Wallpaper_group#Group_p4m_(*442)).

# Extended Help

The array data is stored in a `UInt8`, with pairs of bits represting color values.
The first matrix element is represented by the least significant bits.
"""
struct BayerCFA <: ColorFilterArray{2}
    data::UInt8
    BayerCFA(i::UInt8) = new(_bayer_check(i))
end

"""
    BayerCFA(spec::AbstractString)
    BayerCFA(spec::Symbol)

Constructs a Bayer CFA matrix from a string specifier, either an `AbstractString` or `Symbol`.

Bayer matrices are commonly described in a string, such as "GBRG".
This string represents the matrix layout in a row-first order, so this string maps to
```
G B
R G
```
Note that Julia matrices, including `ColorFilterArray`, are represented in a column-first order.

# Examples
```julia-repl
julia> BayerCFA("GRBG")
Bayer color filter array (GRBG):
 0x02  0x01
 0x03  0x02

julia> BayerCFA(:RGGB)
Bayer color filter array (RGGB):
 0x01  0x02
 0x02  0x03
```
"""
function BayerCFA(spec::AbstractString)
    data  = _channel_to_uint8(spec[1]) << 0x0
    data += _channel_to_uint8(spec[2]) << 0x4
    data += _channel_to_uint8(spec[3]) << 0x2
    data += _channel_to_uint8(spec[4]) << 0x6
    return BayerCFA(data)
end

BayerCFA(spec::Symbol) = BayerCFA(String(spec))

function Base.getindex(cfa::BayerCFA, i::Int)
    @boundscheck checkbounds(cfa, i)
    shift = UInt8(2 * ((i - 1) % length(cfa)))
    mask = 0b11 << shift
    return (cfa.data & mask) >> shift
end

Base.String(cfa::BayerCFA) = join(('X', 'R', 'G', 'B')[n+1] for n in cfa[[1,3,2,4]])

#---Fast transforms of a Bayer matrix--------------------------------------------------------------#

# reflection across a diagonal
function _permutedims(cfa::BayerCFA)
    # some fun bit twiddling
    data = cfa.data & 0b11000011
    i2 = (cfa.data & 0b00110000) >> 0x2
    i3 = (cfa.data & 0b00001100) << 0x2
    return BayerCFA(data | i2 | i3)
end

Base.transpose(cfa::BayerCFA) = _permutedims(cfa)
Base.adjoint(cfa::BayerCFA) = _permutedims(cfa)
Base.permutedims(cfa::BayerCFA) = _permutedims(cfa)

# reflection along axes
function _reverse(cfa::BayerCFA, dim::Integer)
    if dim == 1
        r1 = (cfa.data & 0b00110011) << 0x2
        r2 = (cfa.data & 0b11001100) >> 0x2
        return BayerCFA(r1 | r2)
    elseif dim == 2
        c1 = (cfa.data & 0b00001111) << 0x4
        c2 = (cfa.data & 0b11110000) >> 0x4
        return BayerCFA(c1 | c2)
    end
    throw(ArgumentError("invalid dimension $dim in reverse"))
end

_reverse(cfa::BayerCFA, ::Tuple{}) = cfa
_reverse(cfa::BayerCFA, dims::Tuple{Integer}) = _reverse(cfa, only(dims))
_reverse(cfa::BayerCFA, dims::Tuple{Integer,Integer}) = _reverse(_reverse(cfa, dims[1]), dims[2])

function _reverse(::BayerCFA, dims::Tuple{Vararg{Integer}})
    throw(ArgumentError("invalid dimensions $dims in reverse"))
end

_reverse(cfa::BayerCFA, ::Colon) = _reverse(_reverse(cfa, 1), 2)

Base.reverse(cfa::BayerCFA; dims=:) = _reverse(cfa, dims)

function Base.circshift(::BayerCFA, ::Tuple{Vararg{Integer,N}}) where N
    throw(ArgumentError("input tuple of length $N, requested 2 or less"))
end

function Base.circshift(cfa::BayerCFA, shift::Tuple{Integer,Integer})
    cfa = ifelse(isodd(shift[1]), _reverse(cfa, 1), cfa)
    cfa = ifelse(isodd(shift[2]), _reverse(cfa, 2), cfa)
    return cfa
end

Base.circshift(cfa::BayerCFA, shift::Integer) = circshift(cfa, (shift, zero(shift)))
Base.circshift(cfa::BayerCFA, shift::Tuple{Integer}) = circshift(cfa, only(shift))
Base.circshift(cfa::BayerCFA, ::Tuple{}) = cfa

#---Pretty printing--------------------------------------------------------------------------------#

Base.show(io::IO, cfa::BayerCFA) = print(io, typeof(cfa), "(\"", String(cfa), "\")") 
Base.summary(io::IO, cfa::BayerCFA) = print(io, "Bayer color filter array (", String(cfa), ")")
