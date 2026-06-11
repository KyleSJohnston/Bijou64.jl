# Use `--track-allocation=user` to obtain allocation values by line.
using BenchmarkTools

using Bijou64
using LittleEndianBase128: LittleEndianBase128 as LEB128

include("common.jl")

println()
println("Benchmarking Bijou64 Encoding")
println()

# Range chosen to after viewing https://www.inkandswitch.com/tangents/bijou64/
io = IOContext(stdout, :histmin => 10e3, :histmax => 100e3, :logbins => true)

println("tiny -- Bijou64")
b = @benchmark Bijou64.encode($(tiny_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("tiny -- LEB128")
b = @benchmark LEB128.encode($(tiny_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("small -- Bijou64")
b = @benchmark Bijou64.encode($(small_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("small -- LEB128")
b = @benchmark LEB128.encode($(small_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("medium -- Bijou64")
b = @benchmark Bijou64.encode($(medium_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("medium -- LEB128")
b = @benchmark LEB128.encode($(medium_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("large -- Bijou64")
b = @benchmark Bijou64.encode($(large_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("large -- LEB128")
b = @benchmark LEB128.encode($(large_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("boundary -- Bijou64")
b = @benchmark Bijou64.encode($(boundary_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("boundary -- LEB128")
b = @benchmark LEB128.encode($(boundary_values()))
show(io, MIME("text/plain"), b)
println()
println()


println("uniform -- Bijou64")
b = @benchmark Bijou64.encode($(uniform_values()))
show(io, MIME("text/plain"), b)
println()
println()

println("uniform -- LEB128")
b = @benchmark LEB128.encode($(uniform_values()))
show(io, MIME("text/plain"), b)
println()
println()

