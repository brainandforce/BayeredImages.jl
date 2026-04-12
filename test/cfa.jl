@testset "ColorFilterArray" begin
    @test size(ColorFilterArray{2}) == (2, 2)
    @test IndexStyle(ColorFilterArray{6}) === IndexLinear()
    @test_throws TypeError size(ColorFilterArray{Int})
    input = [1 2; 2 3]
    cfa = GenericCFA{2}(convert.(UInt8, [1 2; 2 3]))
    @test cfa == GenericCFA{2}(input)
    for (n,i) in enumerate(CartesianIndices(cfa))
        @test cfa[n] == input[n]
        @test cfa[i] == input[i]
    end
    @test_throws DimensionMismatch GenericCFA{3}(input)
end
