using Bijou64
using Test

@testset "Tests from Specification" begin

    # https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md#worked-example
    let io = IOBuffer()
        Bijou64.encode(io, UInt64(67_000))
        seekstart(io)
        bytes = take!(io)
        @test bytes == [0xFA, 0x00, 0x03, 0xC0]
    end

    let io = IOBuffer()
        Bijou64.encode(io, UInt64(67_000))
        seekstart(io)
        @test Bijou64.decode(io, UInt64) == 67_000
        @test position(io) == 4
    end

    # https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md#test-vectors

    values = UInt64[
        0,
        1,
        42,
        247,
        248,
        300,
        503,
        504,
        1_000,
        65_535,
        66_039,
        66_040,
        67_000,
        16_843_255,
        16_843_256,
        4_311_810_551,
        72_340_172_838_076_920,
        18_446_744_073_709_551_615,
    ]

    bytes = [
        UInt8[0x00],
        UInt8[0x01],
        UInt8[0x2A],  # 42
        UInt8[0xF7],
        UInt8[0xF8, 0x00],
        UInt8[0xF8, 0x34],  # 300
        UInt8[0xF8, 0xFF],
        UInt8[0xF9, 0x00, 0x00],
        UInt8[0xF9, 0x01, 0xF0],
        UInt8[0xF9, 0xFE, 0x07],
        UInt8[0xF9, 0xFF, 0xFF],
        UInt8[0xFA, 0x00, 0x00, 0x00],
        UInt8[0xFA, 0x00, 0x03, 0xC0],  # 67_000
        UInt8[0xFA, 0xFF, 0xFF, 0xFF],
        UInt8[0xFB, 0x00, 0x00, 0x00, 0x00],
        UInt8[0xFB, 0xFF, 0xFF, 0xFF, 0xFF],
        UInt8[0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        UInt8[0xFF, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0x07],
    ]

    for (v, b) in zip(values, bytes)
        let io = IOBuffer()
            Bijou64.encode(io, v)
            seekstart(io)
            result = take!(io)
            @test result == b
        end
        let io = IOBuffer()
            Bijou64.encode(io, v)
            seekstart(io)
            @test Bijou64.decode(io, UInt64) == v
        end
    end

end
