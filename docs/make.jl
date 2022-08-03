using Documenter
using Ascii85

push!(LOAD_PATH,"../src/")
makedocs(
    sitename = "Ascii85.jl Documentation",
    pages = [
        "Index" => "index.md"
    ],
    format = Documenter.HTML(prettyurls = false),
    modules = [Ascii85]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/pst-lz/Ascii85.jl.git",
    devbranch = "main"
)
