# --- Imports

# Standard library
using Documenter

# Local package
using TestTools

# --- Setup

# Make sure that the Julia source code directory is on LOAD_PATH
push!(LOAD_PATH, "../src/")

# Set up DocMeta
DocMeta.setdocmeta!(TestTools, :DocTestSetup, :(using TestTools); recursive=true)

# --- Generate documentation

makedocs(;
    modules=[TestTools],
    authors="Kevin Chu <kevin@velexi.com> and contributors",
    repo="https://github.com/velexi-corporation/TestTools.jl/blob/{commit}{path}#{line}",
    sitename="TestTools.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/velexi-corporation/TestTools.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Installation" => "install.md",
        "Modules" => "modules.md",
        "Index" => "docs-index.md",
    ],
)

# --- Deploy documentation

deploydocs(; repo="github.com/velexi-corporation/TestTools.jl", devbranch="main")
