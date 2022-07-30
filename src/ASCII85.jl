module ASCII85

# https://en.wikipedia.org/wiki/Ascii85

export ascii85enc!, ascii85dec!, ascii85dec

function ascii85enc!(in::IO, out::IO)
    seekstart(in)
    seekstart(out)
    write(out, "<~")
    seg :: UInt32
    segenc = zeros(5, UInt8)
    while !eof(in)
        seg = ntoh(read(in, UInt32))
        if seg == 0
            write(out, 'z')
        else
            for i in 1:4
                segenc[6 - i] = (seg % 85) + 33
                seg ÷= 85
            end
            segenc[1] = seg +33
        end
        for i in 1:5
            write(out, segenc[i])
        end
    end
    write(out, "~>")


end

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
                    # println(seg)
                    i = 0
                    segtemp = 0
                else
                    error("> 4294967296")
                    break
                end 
            end
        elseif b == 126 # ~
            # println('~')
            b = read(in, UInt8)
            # println(b)
            if b == 62 # finish mark ~>
                # println(i)
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
                # println(seg)
                # println("regular z")
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
                    # println(seg)
                    i = 0
                    segtemp = 0
                else
                    error("> 4294967296")
                    break
                end 
            end
        elseif b == 126 # ~
            # println('~')
            if in[k+1] == 62 # finish mark ~>
                # println(i)
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
                # println("regular z")
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