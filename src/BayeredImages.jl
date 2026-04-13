module BayeredImages

using Base: @propagate_inbounds

include("cfa.jl")
export ColorFilterArray, GenericCFA
include("bayer.jl")
export BayerCFA
#=
include("xtrans.jl")
export XTransCFA
=#
include("images.jl")
export CFAImage, BayeredImage
export get_color_channel
include("demosaicing.jl")
export DemosaicAlgorithm, BilinearDemosaic
export demosaic

end
