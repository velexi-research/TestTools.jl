"""
jltest/utils.jl defines utility functions to support unit testing.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
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
    run_tests(tests::Vector{String}; <keyword arguments>)

Run unit tests contained in the list of files or modules provided in `tests`. If `tests`
is empty, run all tests contained in files present in the current working directory. File
names in `tests` may be specified with or without the `.jl` extension.

# Keyword Arguments

* `mod`: Julia module that tests should be run within
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
    autodetect_tests(; dir::AbstractString=pwd())

Return all Julia files in `dir` that contain unit tests.
"""
function autodetect_tests(; dir::AbstractString=pwd())::Vector{String}
    tests = readdir(dir)
    tests = filter(f -> endswith(f, ".jl") && f != "runtests.jl", tests)

    # TODO: filter `tests` to exclude files that do not contain unit tests

    return tests
end
