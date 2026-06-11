using Documenter
using Bijou64

makedocs(
    sitename="Bijou64.jl",
    modules = [Bijou64],
    checkdocs = :public,
)

deploydocs(
    repo = "github.com/KyleSJohnston/Bijou64.jl.git",
)
