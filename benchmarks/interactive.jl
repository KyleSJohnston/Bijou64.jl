using Bijou64
using Profile

include("common.jl")  # for `small_values`

x = small_values();

@time Bijou64.encode(x);

@code_warntype Bijou64.encode(x);

@allocated Bijou64.encode(x)

# See https://m3g.github.io/JuliaNotes.jl/stable/memory/#Using-the-Profiler
Bijou64.encode(x);  # compile
Profile.clear_malloc_data()  # clear allocations
@profile Bijou64.encode(x);
Profile.print(format=:flat)
