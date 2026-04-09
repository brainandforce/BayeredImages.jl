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
