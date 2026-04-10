module BayeredImagesColorTypesExt

using BayeredImages
using ColorTypes, FixedPointNumbers

_normalized(x::Real) = x
_normalized(x::T) where T<:Unsigned = reinterpret(Normed{T,8*sizeof(T)}, x)

function to_RGB_pixel(pixel::Real, channel::UInt8)
    return RGB(ntuple(n -> _normalized(ifelse(n == channel, pixel, zero(pixel))), Val(3))...)
end

"""
    to_RGB_image(ci::CFAImage) -> AbstractMatrix{<:RGB}

Converts scalar pixel values in a mosaiced image to explicit RGB values.
"""
function to_RGB_image(ci::CFAImage{C,T}) where {C,T<:Integer}
    result = similar(ci, RGB{Normed{T,8*sizeof(T)}})
    for (l, c) in zip(eachindex(ci), CartesianIndices(ci))
        result[l] = to_RGB_pixel(ci[l], ColorFilterArray(ci)[c])
    end
    return result
end

function to_RGB_image(ci::CFAImage{C,T}) where {C,T<:Real}
    result = similar(ci, RGB{T})
    for (l, c) in zip(eachindex(ci), CartesianIndices(ci))
        result[l] = to_RGB_pixel(ci[l], ColorFilterArray(ci)[c])
    end
    return result
end

end
