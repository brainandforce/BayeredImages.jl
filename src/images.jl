"""
    CFAImage{C<:ColorFilterArray,T,M<:AbstractMatrix{T}} <: AbstractMatrix{T}

Represents an raw image from a camera with a color filter array and associated CFA metadata.
"""
struct CFAImage{C<:ColorFilterArray,T,M<:AbstractMatrix{T}} <: AbstractMatrix{T}
    cfa::C
    image::M
end

"""
    BayeredImage{T,M} <: AbstractMatrix{T}

A raw image taken by a sensor with a Bayer matrix.
Alias for [`CFAImage{BayerCFA,T,M}`](@ref).
"""
const BayeredImage{T,M<:AbstractMatrix{T}} = CFAImage{BayerCFA,T,M}

CFAImage{C}(cfa, image::M) where {C,T,M<:AbstractMatrix{T}} = CFAImage{C,T,M}(cfa, image)
# Swap the specified color filter array
CFAImage{C}(cfa::ColorFilterArray, ci::CFAImage{C}) where C = CFAImage{C}(cfa, ci.image)
CFAImage(cfa::C, ci::CFAImage{C}) where C<:ColorFilterArray = CFAImage{C}(cfa, ci.image)

Base.size(ci::CFAImage) = size(ci.image)
Base.IndexStyle(::Type{CFAImage{<:ColorFilterArray,<:Any,M}}) where M = IndexStyle(M)
@propagate_inbounds Base.getindex(ci::CFAImage, i...) = getindex(ci.image, i...)
@propagate_inbounds Base.setindex!(ci::CFAImage, x, i...) = setindex!(ci.image, x, i...)

# Shift the CFA over when cropping an image:
# we know to do this if we're indexing by AbstractUnitRange.
# Otherwise, just return an AbstractMatrix
@propagate_inbounds function Base.getindex(ci::CFAImage, i::AbstractUnitRange, j::AbstractUnitRange)
    return CFAImage(circshift(ci.cfa, first.((i, j)) .- (true, true)), ci.image[i, j])
end

ColorFilterArray(ci::CFAImage) = ci.cfa
(::Type{C})(ci::CFAImage{C}) where C<:ColorFilterArray = ci.cfa

# Needed to resolve method ambiguities
GenericCFA{D}(ci::CFAImage{C}) where {D,C<:GenericCFA{D}} = ci.cfa
GenericCFA{D,M}(ci::CFAImage{C}) where {D,M,C<:GenericCFA{D,M}} = ci.cfa

#---Getting data from each color channel-----------------------------------------------------------#
"""
    get_color_channel(ci::CFAImage, channel::Integer, [default = zero(eltype(ci))])

Extracts the pixels that correspond to the selected color channel.
Pixels not matching the color channel are set to the value `default`.
If the image does not contain data associated with a color channel, an array of `default` is
returned.
"""
function get_color_channel(ci::CFAImage, channel::Integer, default = zero(eltype(ci)))
    result = similar(ci.image)
    cfa = ColorFilterArray(ci)
    for (n,i) in enumerate(CartesianIndices(ci))
        result[n] = ifelse(cfa[i] == channel, ci[n], default)
    end
    return result
end

#---Transforming images while preserving the CFA arrangement---------------------------------------#

function Base.reverse(ci::CFAImage; dims = :)
    cfa = ColorFilterArray(ci)
    reversed_cfa = reverse(circshift(cfa, mod.(size(ci), size(cfa))); dims)
    return CFAImage(reversed_cfa, reverse(ci.image; dims))
end

function Base.reverse!(ci::CFAImage; dims = :)
    cfa = ColorFilterArray(ci)
    reversed_cfa = reverse(circshift(cfa, mod.(size(ci), size(cfa))); dims)
    return CFAImage(reversed_cfa, reverse!(ci.image; dims))
end

#= TODO: handle cases where the image dimensions do not divide the CFA dimensions
function Base.circshift(ci::CFAImage, shifts)
end
=#

Base.permutedims(ci::CFAImage) = CFAImage(permutedims(ci.cfa), permutedims(ci.image))

#---Arithmetic operations--------------------------------------------------------------------------#

Base.:*(ci::CFAImage, x::Number) = CFAImage(ColorFilterArray(ci), ci.image * x)
Base.:*(x::Number, ci::CFAImage) = CFAImage(ColorFilterArray(ci), x * ci.image)
Base.:/(ci::CFAImage, x::Number) = CFAImage(ColorFilterArray(ci), ci.image / x)
Base.:\(x::Number, ci::CFAImage) = CFAImage(ColorFilterArray(ci), x \ ci.image)

#---Pretty printing--------------------------------------------------------------------------------#

function Base.summary(io::IO, bi::BayeredImage)
    join(io, size(bi), '×')
    print(io, ' ', String(BayerCFA(bi)), ' ', typeof(bi))
end
