"""
TODO
"""
# --- Exports

export autodetect_tests, run_tests

# --- Imports

# Standard library
using Test

# External packages
using ArgParse
using Documenter

# --- Functions/Methods

"""
    run_tests(files::Vector{String}; mod=Main)

TODO
Run tests contained in the specified `files`. If no `files` are specified, run all tests
contained in the current working directory.

Arguments
---------
`files`: list of files to run tests within. File names may be specified with or without
the ".jl" extension.

`mod`: Julia module that tests should be run within

Return value
------------
nothing
"""
function run_tests(tests::Vector{String}; mod=Main)
    println()
    for test in tests
        # Construct test file and test module names
        if endswith(test, ".jl")
            file_name = test
            module_name = splitext(test)[1]
        else
            file_name = string(f, ".jl")
            module_name = test
        end

        # Run test
        print(module_name, ": ")
        Base.include(mod, abspath(test))
        println()
    end
end

"""
    autodetect_tests(files::Vector{String})

TODO
Run tests contained in the specified `files`. If no `files` are specified, run all tests
contained in the current working directory.

Arguments
---------
`files`: list of files to run tests within. File names may be specified with or without
the ".jl" extension.

Return value
------------
nothing
"""
function autodetect_tests(tests::Vector{String})::Vector{String}
    tests = readdir(pwd())
    tests = filter(f -> endswith(f, ".jl") && f != "runtests.jl", tests)
    return tests
end
