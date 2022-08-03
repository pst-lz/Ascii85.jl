using Documenter
using Ascii85

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Ascii85.jl Documentation",
    pages = [
        "Index" => "index.md",
        "Ascii85" => "Ascii85.md",
    ],
    format = Documenter.HTML(prettyurls = false)
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/pst-lz/Ascii85.jl.git",
    devbranch = "main"
)
