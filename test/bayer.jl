@testset "Bayer matrix" begin
    # Construction
    @test_throws Exception BayerCFA("GGGG")
    @test_throws Exception BayerCFA("RRBB")
    @test_throws Exception BayerCFA("RRBB")
    @test_throws Exception BayerCFA("RGBG")
    cfa_list = (BayerCFA("RGGB"), BayerCFA("GRBG"), BayerCFA("GBRG"), BayerCFA("BGGR"))
    for cfa in cfa_list
        cfa = BayerCFA("RGGB")
        _cfa = collect(cfa)
        @test cfa == _cfa
        # Geometric transforms
        @test cfa' == _cfa'
        @test transpose(cfa) == transpose(_cfa)
        @test cfa' == transpose(cfa)
        @test reverse(cfa, dims=1) == reverse(_cfa, dims=1)
        @test reverse(cfa, dims=2) == reverse(_cfa, dims=2)
        @test reverse(cfa, dims=(1,2)) == reverse(_cfa, dims=(1,2))
        @test reverse(cfa, dims=(2,1)) == reverse(_cfa, dims=(2,1))
        @test reverse(cfa, dims=:) == reverse(_cfa, dims=:)
        @test_throws ArgumentError reverse(cfa, dims=3)
        @test_throws ArgumentError reverse(cfa, dims=(3,4))
        @test_throws ArgumentError reverse(cfa, dims=(1,2,1))
    end
end
