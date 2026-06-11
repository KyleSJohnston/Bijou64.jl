using Aqua
using Bijou64
using JET
using Test

@testset "Tests from Specification" begin

    # https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md#worked-example
    @test Bijou64.encode(UInt64(67_000)) == [0xFA, 0x00, 0x03, 0xC0]
    @test Bijou64.decode(UInt64, [0xFA, 0x00, 0x03, 0xC0]) == [67_000]

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
        @test Bijou64.encode(v) == b
        @test Bijou64.decode(UInt64, b) == [v]
    end

    # https://github.com/inkandswitch/bijou/blob/main/bijou64/SPEC.md#error-conditions

    @test_throws BufferTooShort Bijou64.decode(UInt64, UInt8[])
    @test_throws BufferTooShort Bijou64.decode(UInt64, UInt8[0xF9, 0x00])
    @test_throws OverflowError Bijou64.decode(UInt64, UInt8[0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])

end

@testset "Type Tests" begin
    for T1 in (UInt8, UInt16, UInt32, UInt64), T2 in (UInt8, UInt16, UInt32, UInt64)
        if sizeof(T2) < sizeof(T1)
            continue
        end
        x = rand(T1, 1028)
        y = Bijou64.encode(x)
        z = Bijou64.decode(T1, y)
        @test x == z
    end
end

@testset "Source Code Tests" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Bijou64)
    end
    @testset "Code inference (JET.jl)" begin
        JET.test_package(Bijou64; target_modules = (Bijou64,))
    end
end
