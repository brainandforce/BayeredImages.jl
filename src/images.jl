"""
    CFAImage{C<:ColorFilterArray,T,M<:AbstractMatrix{T}} <: AbstractMatrix{T}

Represents an raw image from a camera with a color filter array and associated CFA metadata.
"""
struct CFAImage{C<:ColorFilterArray,T,M<:AbstractMatrix{T}} <: AbstractMatrix{T}
    cfa::C
    image::M
end

const BayeredImage{T,M} = CFAImage{BayerCFA,T,M}

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

#---Transforming images while preserving the CFA arrangement---------------------------------------#

#= TODO: ensure that the offsets are handled correctly
Base.reverse!(ci::CFAImage, dims) = CFAImage(reverse(ci.cfa, dims), reverse!(ci.image, dims))
Base.reverse(ci::CFAImage, dims) = CFAImage(reverse(ci.cfa, dims), reverse(ci.image, dims))
=#

#= TODO: handle cases where the image dimensions do not divide the CFA dimensions
function Base.circshift(ci::CFAImage, shifts)
end
=#

Base.permutedims(ci::CFAImage) = CFAImage(permutedims(ci.cfa), permutedims(ci.image))
