using BayeredImages
using StaticArrays
using Aqua, Test

Aqua.test_all(BayeredImages)

const XTRANS_CFA = SMatrix{6,6,UInt8}(
    [ 2 1 3 2 3 1;
      3 2 2 1 2 2;
      1 2 2 3 2 2;
      2 3 1 2 1 3;
      1 2 2 3 2 2;
      3 2 2 1 2 2 ]
)

@testset "BayeredImages.jl" begin
    include("bayer.jl")
end
