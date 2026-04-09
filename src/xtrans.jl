#---Fujifilm X-trans matrix------------------------------------------------------------------------#
"""
    XTransCFA <: ColorFilterArray{6}

Represents the special 6×6 X-Trans color filter array used by Fujifilm cameras.
The matrix is a has twofold rotational symmetry about the indices `[1, 1]`, `[4, 1]`, `[1, 4]`, and
`[4, 4]`, as well as two perpendicular mirror planes through those positions (wallpaper group pmm).
"""
struct XTransCFA
    x::Int8
    y::Int8
    XTransCFA(x, y) = new(x % 6 % Int8, y % 6 % Int8)
end

"""
    XTransCFA([x = 0], [y = 0])

Generates a Fujifilm X-Trans color filter array with a specified offset and mirroring, defaulting
to no offset at all.
"""
XTransCFA() = XTransCFA(Int8(0), Int8(0))

# Put vertical argument first to correspond with Julia being column-first
function Base.getindex(cfa::XTransCFA, i::Int)
    @boundscheck checkbounds(cfa, i)
    # Incorporate offsets
    _i = i - cfa.y - 6*cfa.x
    _i in (2, 6, 10, 13, 21, 23, 25, 34) && return 0x03
    _i in (3, 5,  7, 16, 20, 24, 28, 31) && return 0x01
    return 0x02
end

function _reverse(cfa::XTransCFA, dims::Integer)
    dims == 1 && return XTransCFA(cfa.x, cfa.y + 3 - one(Int8))
    dims == 2 && return XTransCFA(cfa.x + 3 - one(Int8), cfa.y)
    throw(ArgumentError(LazyString("invalid dimensions ", dims, "in reverse!")))
end

function _reverse(cfa::XTransCFA, dims::Tuple{Vararg{Int}})

end

function _reverse(cfa::XTransCFA, ::Colon)
    return XTransCFA(cfa.x - one(Int8), cfa.y - one(Int8))
end

reverse(cfa::XTransCFA; dims=:) = _reverse(cfa, dims)

#=
    Form of the X-Trans matrix:

    G R B G B R
    B G G R G G
    R G G B G G
    G B R G R B
    R G G B G G
    B G G R G G

    Blue at linear indices  2,  6, 10, 13, 21, 23, 25, 34
    Red  at linear indices  3,  5,  7, 16, 20, 24, 28, 31
=#
