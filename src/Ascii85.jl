"""
    Ascii85

    ASCII85 in Julia
"""
module Ascii85

export ascii85enc!, ascii85dec!, ascii85enc, ascii85dec

"""
    ascii85enc!(in::IO, out::IO)
    converts binary data to ASCII85 (Adobe style with <~ ~>)
    # Arguments
    - `in::IO`: an IO with binary data
    - `out::IO`: an empty IO for the ASCII85
"""
function ascii85enc!(in::IO, out::IO)
    seekstart(in)
    seekstart(out)
    write(out, "<~")
    inarr = Array{UInt8}(undef, 0)
    inarr = read(in)
    seg :: UInt32 = 0
    segenc = zeros(UInt8, 5)
    numseg = length(inarr) ÷ 4
    if numseg >= 1
        for j in 1:numseg
            seg = UInt32(inarr[1+4*(j-1)]) << 24 + UInt32(inarr[2+4*(j-1)]) << 16 + UInt32(inarr[3+4*(j-1)]) << 8 + inarr[4+4*(j-1)]
            if seg == 0
                write(out, 'z')
            else
                for i in 1:4
                    segenc[6 - i] = (seg % 85) + 33
                    seg ÷= 85
                end
                segenc[1] = seg +33
                for i in 1:5
                    write(out, segenc[i])
                end
            end
        end
    end
    padding = 0
    while length(inarr) % 4 !=0
        push!(inarr, 0)
        padding += 1
    end
    if padding != 0
        seg = UInt32(inarr[1 + numseg * 4]) << 24 + UInt32(inarr[2 + numseg * 4]) << 16 + UInt32(inarr[3 + numseg * 4]) << 8 + inarr[4 + numseg * 4]
        for i in 1:4
            segenc[6 - i] = (seg % 85) + 33
            seg ÷= 85
        end
        segenc[1] = seg +33
        for i in 1:(5 - padding)
            write(out, segenc[i])
        end
    end
    write(out, "~>")
end

"""
    ascii85enc(inarr::Array{UInt8})
    converts binary data to ASCII85 (Adobe style with <~ ~>)
    # Arguments
    - `inarr::Array{UInt8}`: an IO with binary data
    returns ASCII85 as String
"""
function ascii85enc(inarr::Array{UInt8})
    outstr :: String = "<~"
    seg :: UInt32 = 0
    segenc = zeros(UInt8, 5)
    numseg = length(inarr) ÷ 4
    if numseg >= 1
        for j in 1:numseg
            seg = UInt32(inarr[1+4*(j-1)]) << 24 + UInt32(inarr[2+4*(j-1)]) << 16 + UInt32(inarr[3+4*(j-1)]) << 8 + inarr[4+4*(j-1)]
            if seg == 0
                outstr *= 'z'
            else
                for i in 1:4
                    segenc[6 - i] = (seg % 85) + 33
                    seg ÷= 85
                end
                segenc[1] = seg +33
                for i in 1:5
                    outstr *= Char(segenc[i])
                end
            end
        end
    end
    padding = 0
    while length(inarr) % 4 !=0
        push!(inarr, 0)
        padding += 1
    end
    if padding != 0
        seg = UInt32(inarr[1 + numseg * 4]) << 24 + UInt32(inarr[2 + numseg * 4]) << 16 + UInt32(inarr[3 + numseg * 4]) << 8 + inarr[4 + numseg * 4]
        for i in 1:4
            segenc[6 - i] = (seg % 85) + 33
            seg ÷= 85
        end
        segenc[1] = seg +33
        for i in 1:(5 - padding)
            outstr *= Char(segenc[i])
        end
    end
    outstr *= "~>"
    return outstr
end

"""
    ascii85dec!(in::IO, out::IO)
    converts ASCII85 (Adobe style with <~ ~>) to binary data 
    # Arguments
    - `in::IO`: an IO with ASCII85
    - `out::IO`: an empty IO for the binary data
"""
function ascii85dec!(in::IO, out::IO)
    # for IO with <~ ASCII85 ~>
    seekstart(in)
    seekstart(out)
    startfound = false
    while !eof(in) && !startfound
        s = read(in, Char)
        if s == '<'
            s = read(in, Char)
            if s == '~'
                startfound = true
                break
            end
        end
    end
    seg::UInt32 = 0
    segtemp::UInt64 = 0
    i = 0
    while !eof(in)
        b = read(in, UInt8)
        if b>=33 && b <= 117
            segtemp += (b-33)*85^(4-i)
            i += 1
            if i >= 5
                if segtemp <= 4294967296
                    seg = segtemp
                    write(out, ntoh(seg))
                    i = 0
                    segtemp = 0
                else
                    error("> 4294967296")
                    break
                end 
            end
        elseif b == 126 # ~
            b = read(in, UInt8)
            if b == 62 # finish mark ~>
                if i > 0
                    b = 117
                    for j in i:4
                        segtemp += (b-33)*85^(4-j)
                    end
                    if segtemp <= 4294967296
                        seg = segtemp
                        iotemp = IOBuffer()
                        write(iotemp, ntoh(seg))
                        seekstart(iotemp)
                        for j in 1:(i-1)
                            write(out, read(iotemp, UInt8))
                        end
                    else
                        error("incorrect ASCII85 (error in last segment)")
                        break # error
                    end
                end
                break # finish mark ~>, regular end
            else
                error("irregular ending (~ without >)")
                break # irregular end
            end
        elseif b == 122 # regular z
            if i == 0 # regular z
                seg = 0
                write(out, seg)
            else
                error("irregular placed z")
                break # irregular z
            end
        elseif (b > 117 && b <= 121) || (b >= 123 && b <= 125) || b >= 127
            error("irregular Char")
            break # irregular Char
        end # 0 to 32 whitespace to be ignored
    end
end

"""
    ascii85dec(in)
    converts ASCII85 (Adobe style with <~ ~>) to binary data 
    # Arguments
    - `in::Array{UInt8}` or `in::String`: the ASCII85 to decode
    returns the binary data as Array{UInt8}
"""
function ascii85dec(in::Array{UInt8})
    # for Bytearray with <~ ASCII85 ~>
    out = Array{UInt8}(undef, 0)
    start = 1
    for k in 1:length(in)
        if in[k] == 60 && in[k + 1] == 126
            start = k + 2
            break
        end
    end
    seg::UInt32 = 0
    segtemp::UInt64 = 0
    byte1 = 0xff000000
    byte2 = 0x00ff0000
    byte3 = 0x0000ff00
    byte4 = 0x000000ff
    i = 0
    for k in start:length(in)
        b = in[k]
        if b>=33 && b <= 117
            segtemp += (b-33)*85^(4-i)
            i += 1
            if i >= 5
                if segtemp <= 4294967296
                    seg = segtemp
                    push!(out, (seg & byte1) >> 24)
                    push!(out, (seg & byte2) >> 16)
                    push!(out, (seg & byte3) >> 8)
                    push!(out, seg & byte4)
                    i = 0
                    segtemp = 0
                else
                    error("> 4294967296")
                    break
                end 
            end
        elseif b == 126 # ~
            if in[k+1] == 62 # finish mark ~>
                if i > 0
                    b = 117
                    for j in i:4
                        segtemp += (b-33)*85^(4-j)
                    end
                    if segtemp <= 4294967296
                        seg = segtemp
                        push!(out, (seg & byte1) >> 24)
                        if i > 2
                            push!(out, (seg & byte2) >> 16)
                            if i > 3
                                push!(out, (seg & byte3) >> 8)
                            end
                        end
                    else
                        error("incorrect ASCII85 (error in last segment)")
                        break # error
                    end
                end
                break # finish mark ~>, regular end
            else
                error("irregular ending (~ without >)")
                break # irregular end
            end
        elseif b == 122 # regular z
            if i == 0 # regular z
                seg = 0
                for j in 1:4
                    push!(out, 0)
                end
            else
                error("irregular placed z")
                break # irregular z
            end
        elseif (b > 117 && b <= 121) || (b >= 123 && b <= 125) || b >= 127
            error("irregular Char")
            break # irregular Char
        end # 0 to 32 whitespace to be ignored
    end
    return out
end

function ascii85dec(in::String)
    # for Bytearray with <~ ASCII85 ~>
    out = Array{UInt8}(undef, 0)
    start = 1
    for k in 1:length(in)
        if in[k] == '<' && in[k + 1] == '~'
            start = k + 2
            break
        end
    end
    seg::UInt32 = 0
    segtemp::UInt64 = 0
    byte1 = 0xff000000
    byte2 = 0x00ff0000
    byte3 = 0x0000ff00
    byte4 = 0x000000ff
    i = 0
    for k in start:length(in)
        b = UInt8(in[k])
        if b>=33 && b <= 117
            segtemp += (b-33)*85^(4-i)
            i += 1
            if i >= 5
                if segtemp <= 4294967296
                    seg = segtemp
                    push!(out, (seg & byte1) >> 24)
                    push!(out, (seg & byte2) >> 16)
                    push!(out, (seg & byte3) >> 8)
                    push!(out, seg & byte4)
                    i = 0
                    segtemp = 0
                else
                    error("> 4294967296")
                    break
                end 
            end
        elseif b == 126 # ~
            if in[k+1] == '>' # finish mark ~>
                if i > 0
                    b = 117
                    for j in i:4
                        segtemp += (b-33)*85^(4-j)
                    end
                    if segtemp <= 4294967296
                        seg = segtemp
                        push!(out, (seg & byte1) >> 24)
                        if i > 2
                            push!(out, (seg & byte2) >> 16)
                            if i > 3
                                push!(out, (seg & byte3) >> 8)
                            end
                        end
                    else
                        error("incorrect ASCII85 (error in last segment)")
                        break # error
                    end
                end
                break # finish mark ~>, regular end
            else
                error("irregular ending (~ without >)")
                break # irregular end
            end
        elseif b == 122 # regular z
            if i == 0 # regular z
                seg = 0
                for j in 1:4
                    push!(out, 0)
                end
            else
                error("irregular placed z")
                break # irregular z
            end
        elseif (b > 117 && b <= 121) || (b >= 123 && b <= 125) || b >= 127
            error("irregular Char")
            break # irregular Char
        end # 0 to 32 whitespace to be ignored
    end
    return out
end

end # module
