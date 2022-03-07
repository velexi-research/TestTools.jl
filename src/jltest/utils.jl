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
using Test: AbstractTestSet

# External packages
using ArgParse

# --- Functions/Methods

"""
    run_tests(tests::Union{Vector{<:AbstractString}, AbstractString}; <keyword arguments>)

Run unit tests contained in the list of files or modules provided in `tests`. If `tests`
is an empty list or an empty string, an `ArgumentError` is thrown. File names in `tests`
may be specified with or without the `.jl` extension.

# Keyword Arguments

* `name::AbstractString`: name to use for test set used to group `tests`

* `test_set_type::Type`: type of test set to use to group tests
"""
function run_tests(
    tests::Vector{<:AbstractString};
    name::AbstractString="",
    test_set_type::Type{<:AbstractTestSet}=TestSetPlus,
)
    # --- Handle edge cases

    # No tests to run
    if isempty(tests)
        throw(ArgumentError("`tests` may not be empty"))
    end

    # --- Preparations

    # Get current directory
    cwd = pwd()

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

    @testset test_set_type "$name" begin
        # Run tests files
        if !isempty(test_files)
            for (module_name, file_name) in test_files
                # Restore current directory before each test file is run
                cd(cwd)

                # Run test
                println()
                print(module_name, ": ")
                mod = gensym(module_name)
                @eval module $mod
                Base.include($mod, abspath($file_name))
                end
            end
        end

        # Run tests in directories
        for dir in test_dirs
            run_tests(autodetect_tests(dir))
        end
    end

    return nothing
end

# run_tests(tests::AbstractString) method that converts the argument to a Vector{String}
function run_tests(
    tests::AbstractString;
    name::AbstractString="",
    test_set_type::Type{<:AbstractTestSet}=TestSetPlus,
)
    # --- Handle edge cases

    # No tests to run
    if isempty(tests)
        throw(ArgumentError("`tests` may not be empty"))
    end

    # --- Run tests

    run_tests([tests]; name=name, test_set_type=test_set_type)

    return nothing
end

"""
    autodetect_tests(dir::AbstractString)::Vector{String}

Return all Julia files in `dir` that contain unit tests.
"""
function autodetect_tests(dir::AbstractString)::Vector{String}
    files = filter(f -> endswith(f, ".jl") && f != "runtests.jl", readdir(dir))
    tests = [joinpath(dir, file) for file in files]

    # TODO: filter `tests` to exclude files that do not contain unit tests

    return tests
end
