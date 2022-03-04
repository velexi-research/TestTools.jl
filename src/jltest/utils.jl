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
    run_tests(tests::Vector{<:AbstractString}; <keyword arguments>)

Run unit tests contained in the list of files or modules provided in `tests`. If `tests`
is empty, run all tests contained in files present in the current working directory. File
names in `tests` may be specified with or without the `.jl` extension.

# Keyword Arguments

* `name`: name to use for test set used to group tests

* `test_set_type`: type of test set to use to group tests

* `mod`: Julia module that tests should be run within
"""
function run_tests(
    tests::Vector{<:AbstractString};
    name::AbstractString="",
    test_set_type::Type=TestSetPlus,
    mod=Main,
)
    # --- Preparations

    # Separate tests into files and directories
    test_dirs = []
    test_files = Dict()
    for test in tests
        if isdir(test)
            # `test` is a directory
            push!(test_dirs, test)

        else
            # For test files, construct file and module names
            if endswith(test, ".jl")
                file_name = test
                module_name = splitext(test)[1]
            else
                # `test` is a module
                file_name = join([test, ".jl"])
                module_name = test
            end

            test_files[module_name] = file_name
        end
    end

    # --- Run tests

    # Run tests files
    if !isempty(test_files)
        @testset test_set_type "$name" begin
            for (module_name, file_name) in test_files
                # Run test
                println()
                print(module_name, ": ")
                Base.include(mod, abspath(file_name))
            end
        end
    end

    # Run tests in directories
    for dir in test_dirs
        run_tests(autodetect_tests(dir))
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
