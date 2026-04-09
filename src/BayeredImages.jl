module BayeredImages

include("cfa.jl")
export ColorFilterArray
include("bayer.jl")
export BayerCFA
#=
include("xtrans.jl")
export XTransCFA
=#
include("images.jl")
export CFAImage, BayeredImage
#=
include("demosaicing.jl")
=#

end
