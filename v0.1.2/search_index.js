var documenterSearchIndex = {"docs":
[{"location":"Ascii85.html#The-Ascii85-Module.jl","page":"Ascii85","title":"The Ascii85 Module.jl","text":"","category":"section"},{"location":"Ascii85.html","page":"Ascii85","title":"Ascii85","text":"Ascii85","category":"page"},{"location":"Ascii85.html#Ascii85","page":"Ascii85","title":"Ascii85","text":"Ascii85\n\nASCII85 in Julia\n\n\n\n\n\n","category":"module"},{"location":"Ascii85.html#Module-Index","page":"Ascii85","title":"Module Index","text":"","category":"section"},{"location":"Ascii85.html","page":"Ascii85","title":"Ascii85","text":"Modules = [Ascii85]\nOrder   = [:constant, :type, :function, :macro]","category":"page"},{"location":"Ascii85.html#Detailed-API","page":"Ascii85","title":"Detailed API","text":"","category":"section"},{"location":"Ascii85.html","page":"Ascii85","title":"Ascii85","text":"Modules = [Ascii85]\nOrder   = [:constant, :type, :function, :macro]","category":"page"},{"location":"Ascii85.html#Ascii85.ascii85dec!-Tuple{IO, IO}","page":"Ascii85","title":"Ascii85.ascii85dec!","text":"ascii85dec!(in::IO, out::IO)\nconverts ASCII85 (Adobe style with <~ ~>) to binary data \n# Arguments\n- `in::IO`: an IO with ASCII85\n- `out::IO`: an empty IO for the binary data\n\n\n\n\n\n","category":"method"},{"location":"Ascii85.html#Ascii85.ascii85dec-Tuple{Array{UInt8}}","page":"Ascii85","title":"Ascii85.ascii85dec","text":"ascii85dec(in)\nconverts ASCII85 (Adobe style with <~ ~>) to binary data \n# Arguments\n- `in::Array{UInt8}` or `in::String`: the ASCII85 to decode\nreturns the binary data as Array{UInt8}\n\n# Examples\n```jldoctest\njulia> b = ascii85dec(\"<~&i<X6z&i<X6X3C~>\")\n14-element Vector{UInt8}:\n0x12\n0x34\n0x56\n0x78\n0x00\n0x00\n0x00\n0x00\n0x12\n0x34\n0x56\n0x78\n0xab\n0xcd\n\n\n\n\n\n","category":"method"},{"location":"Ascii85.html#Ascii85.ascii85enc!-Tuple{IO, IO}","page":"Ascii85","title":"Ascii85.ascii85enc!","text":"ascii85enc!(in::IO, out::IO)\nconverts binary data to ASCII85 (Adobe style with <~ ~>)\n# Arguments\n- `in::IO`: an IO with binary data\n- `out::IO`: an IO for the ASCII85\n\n\n\n\n\n","category":"method"},{"location":"Ascii85.html#Ascii85.ascii85enc-Tuple{Array{UInt8}}","page":"Ascii85","title":"Ascii85.ascii85enc","text":"ascii85enc(inarr::Array{UInt8})\nconverts binary data to ASCII85 (Adobe style with <~ ~>)\n# Arguments\n- `inarr::Array{UInt8}`: an IO with binary data\nreturns ASCII85 as String\n\n# Examples\n```jldoctest\njulia> a = ascii85enc(hex2bytes(\"123456780000000012345678abcd\"))\n\"<~&i<X6z&i<X6X3C~>\"\n\n\n\n\n\n","category":"method"},{"location":"index.html#Ascii85.jl","page":"Index","title":"Ascii85.jl","text":"","category":"section"},{"location":"index.html","page":"Index","title":"Index","text":"Documentation for Ascii85.jl","category":"page"}]
}