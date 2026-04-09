@testset "Bayer matrix" begin
    # Construction
    @test_throws Exception BayerCFA("GGGG")
    @test_throws Exception BayerCFA("RRBB")
    @test_throws Exception BayerCFA("RRBB")
    @test_throws Exception BayerCFA("RGBG")
    cfa_list = (BayerCFA("RGGB"), BayerCFA("GRBG"), BayerCFA("GBRG"), BayerCFA("BGGR"))
    for cfa in cfa_list
        _cfa = collect(cfa)
        @test cfa == _cfa
        # Dimension permutation
        @test cfa' == _cfa'
        @test transpose(cfa) == transpose(_cfa)
        @test permutedims(cfa) == permutedims(_cfa)
        @test permutedims(cfa) == transpose(cfa)
        @test permutedims(cfa) == cfa'
        # Reversal along dimensions
        @test reverse(cfa, dims=1) == reverse(_cfa, dims=1)
        @test reverse(cfa, dims=2) == reverse(_cfa, dims=2)
        @test reverse(cfa, dims=(1,2)) == reverse(_cfa, dims=(1,2))
        @test reverse(cfa, dims=(2,1)) == reverse(_cfa, dims=(2,1))
        @test reverse(cfa, dims=:) == reverse(_cfa, dims=:)
        @test_throws ArgumentError reverse(cfa, dims=3)
        @test_throws ArgumentError reverse(cfa, dims=(3,4))
        @test_throws ArgumentError reverse(cfa, dims=(1,2,1))
        # Circular shifts
        @test circshift(cfa, (0, 0)) == circshift(_cfa, (0, 0))
        @test circshift(cfa, (1, 0)) == circshift(_cfa, (1, 0))
        @test circshift(cfa, (0, 1)) == circshift(_cfa, (0, 1))
        @test circshift(cfa, (1, 1)) == circshift(_cfa, (1, 1))
        @test circshift(cfa, (0, 0)) == circshift(cfa, (2, 2))
        @test_throws ArgumentError circshift(cfa, (1, 2, 3))
    end
end
