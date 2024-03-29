using Test, Ascii85

@testset "tests with correct pairs of text" begin
plaintext = Array{String}(undef, 0)
a85text = Array{String}(undef, 0)

# example from https://en.wikipedia.org/wiki/Ascii85
    push!(plaintext, "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.")
    push!(a85text, """<~9jqo^BlbD-BleB1DJ+*+F(f,q/0JhKF<GL>Cj@.4Gp\$d7F!,L7@<6@)/0JDEF<G%<+EV:2F!,O<DJ+*.@<*K0@<6L(Df-\\0Ec5e;DffZ(EZee.Bl.9pF"AGXBPCsi+DGm>@3BB/F*&OCAfu2/AKYi(DIb:@FD,*)+C]U=@3BN#EcYf8ATD3s@q?d\$AftVqCh[NqF<G:8+EV:.+Cf>-FD5W8ARlolDIal(DId<j@<?3r@:F%a+D58'ATD4\$Bl@l3De:,-DJs`8ARoFb/0JMK@qB4^F!,R<AKZ&-DfTqBG%G>uD.RTpAKYo'+CT/5+Cei#DII?(E,9)oF*2M7/c~>""")

    # just 1 to 10 letters
    push!(plaintext, "1")
    push!(a85text, "<~0`~>")

    push!(plaintext, "12")
    push!(a85text, "<~0er~>")

    push!(plaintext, "123")
    push!(a85text, "<~0etN~>")

    push!(plaintext, "1234")
    push!(a85text, "<~0etOA~>")

    push!(plaintext, "12345")
    push!(a85text, "<~0etOA2#~>")

    push!(plaintext, "123456")
    push!(a85text, "<~0etOA2)Y~>")

    push!(plaintext, "1234567")
    push!(a85text, "<~0etOA2)[A~>")

    push!(plaintext, "12345678")
    push!(a85text, "<~0etOA2)[BQ~>")

    push!(plaintext, "123456789")
    push!(a85text, "<~0etOA2)[BQ3<~>")

    push!(plaintext, "1234567890")
    push!(a85text, "<~0etOA2)[BQ3A:~>")

    # enc ascii85enc!
    for i in 1:length(plaintext)
        io1 = IOBuffer(plaintext[i])
        io2 = IOBuffer()
        ascii85enc!(io1, io2)
        seekstart(io2)
        @test String(read(io2)) == a85text[i]
        close(io1)
        close(io2)
    end

    # enc ascii85enc
    for i in 1:length(plaintext)
        plainarr = Vector{UInt8}(plaintext[i])
        @test ascii85enc(plainarr) == a85text[i]    
    end
    
    # decode ascii85dec!
    for i in 1:length(plaintext)
        io1 = IOBuffer(a85text[i])
        io2 = IOBuffer()
        ascii85dec!(io1, io2)
        seekstart(io2)
        @test String(read(io2)) == plaintext[i]
        close(io1)
        close(io2)
    end

    # decode ascii85dec Array{UInt8}
    for i in 1:length(plaintext)
        a85arr = Vector{UInt8}(a85text[i])
        plainarr = Vector{UInt8}(plaintext[i])
        @test ascii85dec(a85arr) == plainarr
    end

    # decode ascii85dec String
    for i in 1:length(plaintext)
        plainarr = Vector{UInt8}(plaintext[i])
        @test ascii85dec(a85text[i]) == plainarr
    end
end


@testset "binary" begin
    binaryhex = Array{String}(undef, 0)
    a85binary = Array{String}(undef, 0)

    push!(binaryhex, "123456780000000012345678abcd")
    push!(a85binary, "<~&i<X6z&i<X6X3C~>")

    # enc ascii85enc!
    for i in 1:length(binaryhex)
        io1 = IOBuffer(hex2bytes(binaryhex[i]))
        io2 = IOBuffer()
        ascii85enc!(io1, io2)
        seekstart(io2)
        @test String(read(io2)) == a85binary[i]
        close(io1)
        close(io2)
    end

    # enc ascii85enc
    for i in 1:length(binaryhex)
        @test ascii85enc(hex2bytes(binaryhex[i])) == a85binary[i]
    end


    # decode ascii85dec!
    for i in 1:length(a85binary)
        io1 = IOBuffer(a85binary[i])
        io2 = IOBuffer()
        ascii85dec!(io1, io2)
        seekstart(io2)
        @test String(read(io2)) == String(hex2bytes(binaryhex[i]))
        close(io1)
        close(io2)
    end

    # decode ascii85dec Array{UInt8}
    for i in 1:length(a85binary)
        a85barr = Vector{UInt8}(a85binary[i])
        @test ascii85dec(a85barr) == hex2bytes(binaryhex[i])
    end

    # decode ascii85dec String
    for i in 1:length(a85binary)
        @test ascii85dec(a85binary[i]) == hex2bytes(binaryhex[i])
    end

end

@testset "errors" begin
    # test with errors
    a85ebinary = Array{String}(undef, 0)

    push!(a85ebinary, "<~&i<Xz6&i<X6X3C~>") # wrong z
    push!(a85ebinary, "<~&i<X6zuuuu&i<X6X3C~>") # > 4294967296
    push!(a85ebinary, "<~uu~>") # incorrect ASCII85 (error in last segment)
    push!(a85ebinary, "<~&i<X6z&i<X6X3C~4") # irregular ending (~ without >)
    push!(a85ebinary, "<~&i<X6z&i<X6X3vC~>") # irregular Char
    push!(a85ebinary, "<~&i<X6z&i<Xw6X3C~>") # irregular Char
    push!(a85ebinary, "<~&iü<X6z&i<X6X3C~>") # irregular Char

    # decode ascii85dec String
    for i in 1:length(a85ebinary)
        @test_throws ErrorException ascii85dec(a85ebinary[i])
    end

    # decode ascii85dec Array{UInt8}
    for i in 1:length(a85ebinary)
        a85ebarr = Vector{UInt8}(a85ebinary[i])
        @test_throws ErrorException ascii85dec(a85ebarr)
    end


    # decode ascii85dec!
    for i in 1:length(a85ebinary)
        io1 = IOBuffer(a85ebinary[i])
        io2 = IOBuffer()
        @test_throws ErrorException ascii85dec!(io1, io2)
        close(io1)
        close(io2)
    end
end








