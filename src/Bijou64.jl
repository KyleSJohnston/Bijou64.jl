module Bijou64

export BufferTooShort
public encode, decode

struct BufferTooShort <: Exception end

tag2tier(tag::UInt8) = tag - 0xF7
tier2tag(tier::UInt8) = 0xF7 + tier

const OFFSETS = (
    0x0000_0000_0000_0000,
    0x0000_0000_0000_00F8,  # 248
    0x0000_0000_0000_01F8,
    0x0000_0000_0001_01F8,
    0x0000_0000_0101_01F8,
    0x0000_0001_0101_01F8,
    0x0000_0101_0101_01F8,
    0x0001_0101_0101_01F8,
    0x0101_0101_0101_01F8,
)

tier2offset(tier::T) where {T <: Unsigned} = OFFSETS[tier + one(T)]

function value2tier(v::T) where {T <: Unsigned}
    if T(0x00) ≤ v < T(0xF8)
        return 0x00
    elseif T(0xF8) ≤ v < T(0x01F8)
        return 0x01
    elseif T(0x01F8) ≤ v < T(0x0101F8)
        return 0x02
    elseif T(0x0101F8) ≤ v < T(0x010101F8)
        return 0x03
    elseif T(0x010101F8) ≤ v < T(0x01_010101F8)
        return 0x04
    elseif T(0x01_010101F8) ≤ v < T(0x0101_010101F8)
        return 0x05
    elseif T(0x0101_010101F8) ≤ v < T(0x010101_010101F8)
        return 0x06
    elseif T(0x010101_010101F8) ≤ v < T(0x01010101_010101F8)
        return 0x07
    else
        return 0x08
    end
end


function decode!(results::Vector{T}, bytes::Vector{UInt8}) where {T <: Unsigned}
    if length(bytes) == 0
        throw(BufferTooShort())
    end

    payload_bytes = zeros(UInt8, sizeof(T))
    i = firstindex(bytes)
    n = lastindex(bytes)
    while i ≤ n
        tagbyte = bytes[i]

        if tagbyte < 0xf8  # 248
            push!(results, tagbyte)
        else
            tier = tagbyte - 0xf7  # 247
            padding = sizeof(T) - tier
            for j in eachindex(payload_bytes)
                if j ≤ padding
                    payload_bytes[j] = 0x00
                else
                    i = nextind(bytes, i)
                    try
                        payload_bytes[j] = bytes[i]
                    catch e
                        if e isa BoundsError
                            throw(BufferTooShort())
                        else
                            rethrow()
                        end
                    end
                end
            end
            payload_array::Vector{T} = reinterpret(T, payload_bytes)
            payload = ntoh(payload_array[1])
            value = tier2offset(tier) + payload
            if tier == 8 && value < payload
                throw(OverflowError("overflow detected"))
            end
            push!(results, value)
        end
        i = nextind(bytes, i)
    end
    return results
end

function decode(::Type{T}, bytes::Vector{UInt8}) where {T <: Unsigned}
    results = T[]
    return decode!(results, bytes)
end

function encode!(bytes::Vector{UInt8}, values::Vector{T}) where {T <: Unsigned}
    i = firstindex(bytes)
    for v in values
        if v < T(248)
            bytes[i] = v
        else
            tier = value2tier(v)
            bytes[i] = tier2tag(tier)
            payload = hton(v - tier2offset(tier))  # big-endian unsigned integer
            payload_bytes = reinterpret(UInt8, [payload])[end-tier+1 : end]
            for pb in payload_bytes
                i = nextind(bytes, i)
                bytes[i] = pb
            end
        end
        i = nextind(bytes, i)
    end
    return bytes[begin:prevind(bytes, i)]
end

function encode(values::Vector{T}) where {T <: Unsigned}
    bytes = Vector{UInt8}(undef, 9 * length(values))
    return encode!(bytes, values)
end

encode(v::T) where {T <: Unsigned} = encode([v])

end # module Bijou64
