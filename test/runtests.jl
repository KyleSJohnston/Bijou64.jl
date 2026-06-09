using Bijou64
using Test

@testset "Tests from Specification" begin

    # https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md#worked-example
    io = IOBuffer()
    Bijou64.encode(io, UInt64(67_000))
    seekstart(io)
    bytes = take!(io)
    @test bytes == [0xFA, 0x00, 0x03, 0xC0]
    
    io = IOBuffer()
    Bijou64.encode(io, UInt64(67_000))
    seekstart(io)
    @test Bijou64.decode(io, UInt64) == 67_000
    @test position(io) == 4

end