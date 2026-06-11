"""
bijou64 variable-length integer encoding
"""
module Bijou64

using Compat

export BufferTooShort
@compat public encode, decode

# Bijou64 only handles unsigned integers of 64 bits or less
const UNSIGNED = Union{UInt8,UInt16,UInt32,UInt64}

"Exception indicating that the byte buffer (vector) is too short"
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

tier2offset(tier::T) where {T <: UNSIGNED} = OFFSETS[tier + one(T)]

function value2tier(v::T)::UInt8 where {T <: UNSIGNED}
    if 0x00 ≤ v < 0xF8
        return 0x00
    elseif 0xF8 ≤ v < 0x01F8
        return 0x01
    elseif 0x01F8 ≤ v < 0x0101F8
        return 0x02
    elseif 0x0101F8 ≤ v < 0x010101F8
        return 0x03
    elseif 0x010101F8 ≤ v < 0x01_010101F8
        return 0x04
    elseif 0x01_010101F8 ≤ v < 0x0101_010101F8
        return 0x05
    elseif 0x0101_010101F8 ≤ v < 0x010101_010101F8
        return 0x06
    elseif 0x010101_010101F8 ≤ v < 0x01010101_010101F8
        return 0x07
    else
        return 0x08
    end
end


"""
    decode(T, bytes)::Vector{T}

Decode `bytes` using the bijou64 variable-length integer encoding into a vector
of unsigned integers of type `T`

`T` may be UInt8, UInt16, UInt32, or UInt64.

A `BufferTooShort` exception is thrown if `bytes` is empty or if `bytes` has too few
elements for the tier of the encoded integer.

An `OverflowError` is thrown if there is an arithmetic overflow on tier 8 or if a tier
of encoded integer is too large for `T`.
"""
function decode(::Type{T}, bytes::Vector{UInt8})::Vector{T} where {T <: UNSIGNED}
    if length(bytes) == 0
        throw(BufferTooShort())
    end

    # Pre-allocate the results array as if each of the encoded integers fit into a
    # single byte.
    results = Vector{T}(undef, length(bytes))

    ix = firstindex(results)
    payload_bytes = zeros(UInt8, sizeof(T))
    i = firstindex(bytes)
    n = lastindex(bytes)
    while i ≤ n
        tagbyte = bytes[i]

        if tagbyte < 0xf8  # 248
            results[ix] = tagbyte
        else
            tier = tagbyte - 0xf7  # 247
            if tier > sizeof(T)
                throw(OverflowError("cannot decode tier $tier integer into a $T"))
            end
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
            # On the next line, we can treat `payload_array` as Vector{T}, but
            # adding `::Vector{T}` causes substantial memory allocation.
            payload_array = reinterpret(T, payload_bytes)
            payload = ntoh(payload_array[1])
            value = tier2offset(tier) + payload
            if tier == 8 && value < payload
                throw(OverflowError("overflow detected"))
            end
            results[ix] = value
        end
        i = nextind(bytes, i)
        ix = nextind(results, ix)
    end
    return results[begin:prevind(results, ix)]
end


"""
    encode(values)

Encode `values` using the bijou64 variable-length integer encoding into a Vector{UInt8}

`values` must be a `Vector{T}`, where `T` may be UInt8, UInt16, UInt32, or UInt64.
"""
function encode(values::Vector{T})::Vector{UInt8} where {T <: UNSIGNED}
    if length(values) == 0
        return UInt8[]
    end

    # Pre-allocate an array for the results and fill it.
    # `maxbytes` inspired by https://github.com/davidssmith/LittleEndianBase128.jl/blob/85f2c1e6b8041e9bcfbab897e673a0a45186d3db/src/LittleEndianBase128.jl#L38
    maxbytes = length(values) * (0x01 + value2tier(typemax(T)))
    bytes = Vector{UInt8}(undef, maxbytes)

    # Pre-allocate payload array for `reinterpret` in the loop.
    # This avoids incurring the cost of temporary array construction
    # during each iteration.
    # The eltype is UInt64 because `tier2offset` always returns a UInt64.
    payload = Vector{UInt64}(undef, 1)

    i = 1  # firstindex(bytes)
    for v in values
        if v < 248  # T(248)
            bytes[i] = v
        else
            tier = value2tier(v)
            bytes[i] = tier2tag(tier)
            payload[1] = hton(v - tier2offset(tier))  # big-endian unsigned integer
            payload_bytes = @views reinterpret(UInt8, payload)[end-tier+1 : end]
            for pb in payload_bytes
                i += 1  # nextind(bytes, i)
                bytes[i] = pb
            end
        end
        i += 1  # nextind(bytes, i)
    end
    return bytes[begin:i-1]
end


"""
    encode(v)

Encode `v` using the bijou64 variable-length integer encoding into a Vector{UInt8}

`v` must be a UInt8, a UInt16, a UInt32, or a UInt64.
"""
encode(v::T) where {T <: UNSIGNED} = encode([v])

end # module Bijou64
