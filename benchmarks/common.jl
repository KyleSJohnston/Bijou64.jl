const DEFAULT_BATCH_SIZE = 4086

tiny_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(0):UInt64(247), n)
small_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(248):UInt64(65_535), n)
medium_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64(65_536):UInt64(4_294_967_295), n)
large_values(n=DEFAULT_BATCH_SIZE) = rand(typemax(UInt32)+1:typemax(UInt64), n)
function boundary_values(n=DEFAULT_BATCH_SIZE)
    tier_edges = UInt64[
        Bijou64.tier2offset(0x00),
        Bijou64.tier2offset(0x01)-1,
        Bijou64.tier2offset(0x01),
        Bijou64.tier2offset(0x02)-1,
        Bijou64.tier2offset(0x02),
        Bijou64.tier2offset(0x03)-1,
        Bijou64.tier2offset(0x03),
        Bijou64.tier2offset(0x04)-1,
        Bijou64.tier2offset(0x04),
        Bijou64.tier2offset(0x05)-1,
        Bijou64.tier2offset(0x05),
        Bijou64.tier2offset(0x06)-1,
        Bijou64.tier2offset(0x06),
        Bijou64.tier2offset(0x07)-1,
        Bijou64.tier2offset(0x07),
        Bijou64.tier2offset(0x08)-1,
        Bijou64.tier2offset(0x08),
        typemax(UInt64),
    ]
    return rand(tier_edges, n)
end
uniform_values(n=DEFAULT_BATCH_SIZE) = rand(UInt64, n)
