module Bijou64

tag2tier(tag::UInt8) = tag - 0xF7
tier2tag(tier::UInt8) = 0xF7 + tier

function _tier2offset(tier::Integer)::UInt8
    if tier == 0
        return 0x00
    elseif tier == 1
        return 0xF8  # 248
    elseif tier == 2
        return offset(tier-1) + 256^(tier-1)
    else
        throw(ArgumentError("invalid tier $tier"))
    end
end


function tier2offset(tier::Integer)
    if tier == 0
        return 0x00
    elseif tier == 1
        return 0xF8  # 248
    elseif tier == 2
        return 0x1F8
    elseif tier == 3
        return 0x101F8
    elseif tier == 4
        return 0x10101F8
    elseif tier == 5
        return 0x1010101F8
    elseif tier == 6
        return 0x101010101F8
    elseif tier == 7
        return 0x10101010101F8
    elseif tier == 8
        return 0x1010101010101F8
    else
        throw(ArgumentError("invalid tier $tier"))
    end
end

function value2tier(v::Unsigned)::UInt8
    if 0x00 ≤ v < 0xF8
        return 0
    elseif 0xF8 ≤ v < 0x01F8
        return 1
    elseif 0x01F8 ≤ v < 0x0101F8
        return 2
    elseif 0x0101F8 ≤ v < 0x010101F8
        return 3
    elseif 0x010101F8 ≤ v < 0x01_010101F8
        return 4
    elseif 0x01_010101F8 ≤ v < 0x0101_010101F8
        return 5
    elseif 0x0101_010101F8 ≤ v < 0x010101_010101F8
        return 6
    elseif 0x010101_010101F8 ≤ v < 0x01010101_010101F8
        return 7
    else
        return 8
    end
end


function decode(io::IO, ::Type{T}) where {T <: Unsigned}
    tagbyte = Base.read(io, UInt8)
    if tagbyte < tier2offset(1)
        return tagbyte
    else
        tier = tagbyte - (tier2offset(1) - 1)
        payload_bytes::Vector{UInt8} = Base.read(io, tier)
        while length(payload_bytes) < sizeof(T)
            # big-endian --> add padding to the front
            pushfirst!(payload_bytes, 0x00)
        end
        payload_array::Vector{T} = reinterpret(T, payload_bytes)
        payload = ntoh(payload_array[1])
        return tier2offset(tier) + payload
    end
end



function encode(io::IO, v::Unsigned)
    if v < 248
        Base.write(io, v)
    else
        tier = value2tier(v)
        Base.write(io, tier2tag(tier))
        payload = hton(v - tier2offset(tier))  # big-endian unsigned integer
        Base.write(io, reinterpret(UInt8, [payload])[end-tier+1 : end])
    end
end

end # module Bijou64
