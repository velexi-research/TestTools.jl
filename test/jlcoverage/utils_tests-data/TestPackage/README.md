This package is used to test the `jlcoverage` module. To regenerate the coverage data
used by the unit tests for `jlcoverage`, start `julia` in this directory and run
`Pkg.test(coverage=true)` in the Julia REPL:

    ```julia
    julia> import Pkg; Pkg.test(coverage=true)
    ```
