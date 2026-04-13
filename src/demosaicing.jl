#---Future home for demosaicing algorithms---------------------------------------------------------#
"""
    DemosaicAlgorithm

Supertype for all algorithms used to demosaic a raw color image.
Subtypes should include any needed parameters for executing the algorithm as fields.

To implement a demosaicing algorithm, add a method of the form 
```
BayeredImages.demosaic(alg::DA, image::CFAImage{C})
```
where `DA` is your subtype of `DemosaicAlgorithm`, and `C` is a subtype of `ColorFilterArray`.
"""
abstract type DemosaicAlgorithm
end

"""
    BilinearDemosaic

Demosaics a raw color image by bilinear interpolation.
"""
struct BilinearDemosaic <: DemosaicAlgorithm
end

struct DownsampleDemosaic <: DemosaicAlgorithm
end

"""
    demosaic(alg::DemosaicAlgorithm, ci::CFAImage)

Demosaics a raw image with a chosen algorithm.
The output of a demosaic operation is a 3D array, with the first dimension corresponding to the
number of color channels.
"""
function demosaic end

function demosaic(::BilinearDemosaic, bi::BayeredImage)
    T = float(eltype(bi))
    result = similar(bi.image, T, 3, size(bi)...)
    cfa = ColorFilterArray(bi)
    # Cache CFA data around each point
    local_kernels = stack(
        T.(cfa[CartesianIndices((i[1] .+ (-1:1), i[2] .+ (-1:1)))] .== j)
        for i in CartesianIndices(cfa), j in 1:3
    )
    for i in CartesianIndices(bi)
        # Find all nearby pixels of the same color
        neighborhood = CartesianIndices((i[1] .+ (-1:1), i[2] .+ (-1:1)))
        for j in 0x01:0x03
            lk = @view local_kernels[:, :, mod1.(Tuple(i), size(cfa))..., j]
            sn = sd = zero(eltype(result))
            for (n,k) in zip(neighborhood, eachindex(lk))
                tmp = lk[k] * (n in CartesianIndices(bi))
                sn += tmp * get(bi, n, zero(eltype(result)))
                sd += tmp
            end
            result[j,i] = sn / sd
        end
    end
    return result
end
