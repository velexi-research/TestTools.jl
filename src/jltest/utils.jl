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
    for test in tests
        # Construct test file and test module names
        if endswith(test, ".jl")
            test_file = test
            module_name = splitext(test)[1]
        else
            if isdir(test)
                # `test` is a directory
                subtests = autodetect_tests(test)
                run_tests(subtests)

                # Skip to next item in `tests`
                continue
            else
                # `test` is a module
                test_file = join([test, ".jl"])
                module_name = test
            end
        end

        # Run test
        println()
        print(module_name, ": ")
        Base.include(mod, abspath(test_file))
    end
end

"""
    autodetect_tests(dir::AbstractString)

Return all Julia files in `dir` that contain unit tests.
"""
function autodetect_tests(dir::AbstractString)::Vector{String}
    files = filter(f -> endswith(f, ".jl") && f != "runtests.jl", readdir(dir))
    tests = [joinpath(dir, file) for file in files]

    # TODO: filter `tests` to exclude files that do not contain unit tests

    return tests
end
