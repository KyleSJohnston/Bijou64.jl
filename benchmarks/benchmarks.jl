using BenchmarkTools

using Bijou64
using LittleEndianBase128: LittleEndianBase128 as LEB128

const DEFAULT_BATCH_SIZE = 4086

tiny_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(0):UInt64(247), n)
small_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(248):UInt64(65_535), n)
medium_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(65_536):UInt64(4_294_967_295), n)
large_values(n=DEFAULT_BATCH_SIZE) = rand(typemax(UInt32)+1:typemax(UInt64), n)
function boundary_values(n=DEFAULT_BATCH_SIZE)
    tier_edges = UInt64[
        Bijou64.tier2offset(0),
        Bijou64.tier2offset(1)-1,
        Bijou64.tier2offset(1),
        Bijou64.tier2offset(2)-1,
        Bijou64.tier2offset(2),
        Bijou64.tier2offset(3)-1,
        Bijou64.tier2offset(3),
        Bijou64.tier2offset(4)-1,
        Bijou64.tier2offset(4),
        Bijou64.tier2offset(5)-1,
        Bijou64.tier2offset(5),
        Bijou64.tier2offset(6)-1,
        Bijou64.tier2offset(6),
        Bijou64.tier2offset(7)-1,
        Bijou64.tier2offset(7),
        Bijou64.tier2offset(8)-1,
        Bijou64.tier2offset(8),
        typemax(UInt64),
    ]
    return rand(tier_edges, n)
end
uniform_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64, n)

make_buffer(n=DEFAULT_BATCH_SIZE) = IOBuffer(sizehint=9n)

println()
println("Benchmarking Bijou64")
println()

# Range chosen to after viewing https://www.inkandswitch.com/tangents/bijou64/
io = IOContext(stdout, :histmin => 10e3, :histmax => 100e3, :logbins => true)

println("tiny -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(tiny_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("tiny -- LEB128")
b = @benchmark LEB128.encode($(tiny_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("small -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(small_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("small -- LEB128")
b = @benchmark LEB128.encode($(small_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("medium -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(medium_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("medium -- LEB128")
b = @benchmark LEB128.encode($(medium_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("large -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(large_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("large -- LEB128")
b = @benchmark LEB128.encode($(large_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("boundary -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(boundary_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("boundary -- LEB128")
b = @benchmark LEB128.encode($(boundary_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("uniform -- Bijou64")
b = @benchmark Bijou64.write($(make_buffer()), $(uniform_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("uniform -- LEB128")
b = @benchmark LEB128.encode($(uniform_values()))
show(io, MIME("text/plain"), b)
println()
println()

