module ASCII85

#https://en.wikipedia.org/wiki/Ascii85

export ascii85dec!

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
                    println("> 4294967296")
                    break # error
                end 
            end
        elseif b == 126 # ~
            println('~')
            b = read(in, UInt8)
            println(b)
            if b == 62 # finish mark ~>
                println(i)
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
                        println("error last segment")
                        break # error
                    end
                end
                break # finish mark ~>, regular end
            else
                println("~ without >")
                break # irregular end
            end
        elseif b == 'Z' # regular Z
            if i == 0 # regular Z
                seg = 0
                write(out, seg)
            else
                println("irregular Z")
                break # irregular Z
            end
        elseif (b > 117 && b <= 121) || (b >= 123 && b <= 125) || b >= 127
            println("irregular Char")
            break # irregular Char
        end # 0 to 32 whitespace to be ignored
    end
end

# test1 = """<~9jqo^BlbD-BleB1DJ+*+F(f,q/0JhKF<GL>Cj@.4Gp\$d7F!,L7@<6@)/0JDEF<G%<+EV:2F!,O<DJ+*.@<*K0@<6L(Df-\\0Ec5e;DffZ(EZee.Bl.9pF"AGXBPCsi+DGm>@3BB/F*&OCAfu2/AKYi(DIb:@FD,*)+C]U=@3BN#EcYf8ATD3s@q?d\$AftVqCh[NqF<G:8+EV:.+Cf>-FD5W8ARlolDIal(DId<j@<?3r@:F%a+D58'ATD4\$Bl@l3De:,-DJs`8ARoFb/0JMK@qB4^F!,R<AKZ&-DfTqBG%G>uD.RTpAKYo'+CT/5+Cei#DII?(E,9)oF*2M7/c~>"""
# io1 = IOBuffer()
# io2 = IOBuffer()
# write(io1, test1)
# ascii85dec!(io1, io2)
# seekstart(io2)
# a = ""
# a = String(read(io2))
# println(a)

# test2 = """<~6"FnCAKZ/-EcYr5D@/[?Ddm9#@:X:qFCeu*FD,5.@UX=l@j#6&Ddac"DI[TqBl7Q7+C]J8+EqOABHVA4BkM+\$+Cf(nDJ*O%/0JA=A0>MnG%De1F<G[=AKYl!D.OhUF(8ou3&N<2<+ohc@q]:k@:OCjEcW@GF(Jl)@<,p%FD,5.5uU-B8K_MV@<,ddFCfK6+>Yer-m:#^FD,]5F_>A10ekU0.!6s]Bl7EsF`V8?AKWCCD]j(3E,oN2ASuT4FD,5.@UX=h/N>U1A8,[jFE8QY+EV:;Dfo]++?22,/0K%QB4Z0uATAo;Bln#2FD,5.Ch7^1ATAo>+=LZ>+CQC6E+NNn@;I&r@<6!&FDi:BAT2[\$F(K62+CQBK1+csLF<E7[G%#30ALT/Q@;]TuGA(]4AKZ&5@:NjkBlbD2B5VX.ARmD96"FnCAKZ,:ATJu9BOr;sASc'tBlmp,+<l7u+s:uG+DkP-CER_4AKYQ%A0>f&+CT.16\$\$OMBfIt%ASu!rA7]9oF*)G:DJ()#DIal1AT2[\$F(K62F!,R<AKYf#DJ+')+C]U=FE2MA@psInDJ()6BOr;uBl7?q+D5_5F`9Aa8S0)eBOr<&@<6N5@VfsmCERP-+EMIDEarZ'@X3',F!+t2DKK<\$DK?q4ATq^++EV:*DBLbY@X3',F"AGUBOr;qCi<g!+DGm>E+*9fARlp-Bln#2F`8IFD]ghYDKTc3+C]V<ATJu'AS,k\$AKYQ%@rGmlDJ(RE6"Y4MEZeq2@rGmlDJ(LC@<3Q.@;^?5@X3',F!+n4+EqC;AKYDlA7]9o@<3Q1@:Wn_DJ()#Eb-A6ASl@/ARloqEc5e;FD,5.ASu\$\$De:,6BOr<)F`_SFF=m~>"""
# io3 = IOBuffer()
# io4 = IOBuffer()
# write(io3, test2)
# ascii85dec!(io3, io4)
# seekstart(io4)
# a = String(read(io4))
# println(a)

# test3 = """<~6"FnCAKZ/-EcV~>"""
# io5 = IOBuffer()
# io6 = IOBuffer()
# write(io5, test3)
# ascii85dec!(io5, io6)
# seekstart(io6)
# a = String(read(io6))
# println(a)


# from tom's data onion
# function startsuche(in::IO)
#     while !eof(io1)
#         s = read(io1, Char)
#         if s == '<'
#             break
#         end
#     end
# end
# function ascii85dec(in::IO, out::IO)
#     seg::UInt32 = 0
#     i = 0
#     while !eof(io1)
#         b = read(io1, UInt8)
#         if b == '~'
#             break
#         elseif b == 'z'
#             seg = 0
#             i = 0
#             write(io2, seg)
#         elseif b>=33 && b<= 117
#             seg += (b-33)*85^(4-i)
#             i += 1
#             if i >= 5
#                 write(io2, ntoh(seg))
#                 i = 0
#                 seg = 0
#             end
#         end
#     end
# end
# startsuche(io1)
# ascii85dec(io1, io2)

end # module
