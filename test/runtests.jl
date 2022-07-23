using Test, ASCII85

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

    # decode ascii85dec
    for i in 1:length(plaintext)
        a85arr = zeros(UInt8, length(a85text[i]))
        plainarr = zeros(UInt8, length(plaintext[i]))
        for j in 1:length(a85text[i])
            a85arr[j] = a85text[i][j]
        end
        for j in 1:length(plaintext[i])
            plainarr[j] = plaintext[i][j]
        end
        @test ascii85dec(a85arr) == plainarr
    end
end

@testset "binary" begin
    binaryhex = Array{String}(undef, 0)
    a85binary = Array{String}(undef, 0)

    push!(binaryhex, "123456780000000012345678abcd")
    push!(a85binary, "<~&i<X6z&i<X6X3C~>")

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

    # decode ascii85dec
    for i in 1:length(a85binary)
        a85barr = zeros(UInt8, length(a85binary[i]))
        for j in 1:length(a85binary[i])
            a85barr[j] = a85binary[i][j]
        end
        @test ascii85dec(a85arr) == hex2bytes(binaryhex[i])
    end

end









