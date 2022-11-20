#   Copyright 2022 Velexi Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
jltest/utils.jl defines utility functions to support testing.
"""

# --- Exports

export find_tests, run_tests

# --- Imports

# Standard library
using Logging
using Test
using Test: AbstractTestSet

# External packages
using Suppressor: @capture_err, @suppress_err

# --- Private utility functions

"""
    run_all_tests(test_files::Vector{<:AbstractString})

Run all tests contained in `test_files`.
"""
function run_all_tests(test_files::Vector{<:AbstractString})

    # Get current directory
    cwd = pwd()

    # Run tests files
    if !isempty(test_files)
        for test_file in test_files
            # Restore current directory before each test file is run
            cd(cwd)

            # Construct an isolated module to run the tests contained in test_file
            module_name = splitext(relpath(test_file, cwd))[1]
            testing_module = Module(gensym(module_name))
            @eval testing_module begin
                using Base: eval
                include(p) = Base.include($testing_module, p)
            end

            # Run tests, capturing log messages
            println()
            print(module_name, ": ")
            Base.include(testing_module, abspath(test_file))
        end
    end
end

"""
    get_test_statistics(test_set::EnhancedTestSet{DefaultTestSet})

Compute test statistics for `test_set`.
"""
function get_test_statistics(test_set::EnhancedTestSet{DefaultTestSet})
    # Initialize test statistics
    stats = get_test_statistics(nothing)

    # Get cumulative statistics for `test_set`
    counts = Test.get_test_counts(test_set.wrapped)
    stats[:pass] = counts[1] + counts[5]
    stats[:fail] = counts[2] + counts[6]
    stats[:error] = counts[3] + counts[7]
    stats[:broken] = counts[4] + counts[8]

    return stats
end

function get_test_statistics(test_set::DefaultTestSet)
    # Initialize test statistics
    stats = get_test_statistics(nothing)

    # Get cumulative statistics for `test_set`
    counts = Test.get_test_counts(test_set)
    stats[:pass] = counts[1] + counts[5]
    stats[:fail] = counts[2] + counts[6]
    stats[:error] = counts[3] + counts[7]
    stats[:broken] = counts[4] + counts[8]

    return stats
end

function get_test_statistics(test_set)
    return Dict(:pass => 0, :fail => 0, :error => 0, :broken => 0)
end

# --- Functions/Methods

"""
    run_tests(tests::Vector; <keyword arguments>)
    run_tests(tests::AbstractString; <keyword arguments>)

Run tests in the list of files or modules provided in `tests`. If `tests` is an empty list
or an empty string, an `ArgumentError` is thrown. File names in `tests` may be specified
with or without the `.jl` extension.

Returns a Dict containing statistis test statistics: total number of passed tests,
failed tests, errors, and broken tests.

# Keyword Arguments

* `desc::AbstractString`: description to use for test set used to group `tests`.
  Default: the default description set by `@testset`

* `test_set_type::Type`: type of test set to use to group tests. When `test_set_type`
  is set to `nothing`, the tests are run individually.
  Default: `EnhancedTestSet{DefaultTestSet}`

  !!! note
      When the `JLTEST_FAIL_FAST` environment variable is set to "true", the `test_set_type`
      argument is overridden and set to `EnhancedTestSet{Test.FallbackTestSet}` so that
      tests are run in fail-fast mode.

* `test_set_options::String`: TODO

* `recursive::Bool`: flag indicating whether or not to run tests found in subdirectories
  of directories in `tests`. Default: `true`

* `exclude_runtests::Bool`: flag indicating whether or not to exclude files named
  `runtests.jl` from the list of test files that are run. Default: `true`
"""
function run_tests(
    tests::Vector;
    desc::AbstractString="",
    test_set_type::Union{Type{<:AbstractTestSet},Nothing}=EnhancedTestSet{DefaultTestSet},
    test_set_options::AbstractString="",
    recursive::Bool=true,
    exclude_runtests::Bool=true,
)
    # --- Check arguments

    # Ensure that `tests` is not empty
    if isempty(tests)
        throw(ArgumentError("`tests` may not be empty"))
    end

    # Ensure that `tests` contains strings
    tests = convert(Vector{String}, tests)

    # Enable fail-fast if JLTEST_FAIL_FAST environment variable is set to "true"
    if lowercase(get(ENV, "JLTEST_FAIL_FAST", "false")) == "true"
        test_set_type = EnhancedTestSet{Test.FallbackTestSet}
    end

    # --- Preparations

    test_files = Vector{String}()

    for test in tests
        if isdir(test)
            # Find tests contained in the directory
            test_files = vcat(
                test_files,
                find_tests(test; recursive=recursive, exclude_runtests=exclude_runtests),
            )
        else
            # Get the file name
            file_name = test
            if !endswith(file_name, ".jl")
                # `test` is a module, so append ".jl"
                file_name = join([file_name, ".jl"])
            end

            push!(test_files, file_name)
        end
    end

    # --- Run tests

    if isnothing(test_set_type)
        run_all_tests(test_files)
        test_results = nothing
    else
        if isempty(desc)
            expr = quote
                test_results = @testset test_set_type $test_set_options begin
                    run_all_tests(test_files)
                end
            end
            eval(expr)
        else
            expr = quote
                test_results = @testset test_set_type $test_set_options "$desc" begin
                    run_all_tests(test_files)
                end
            end
            eval(expr)
        end
    end

    test_stats = get_test_statistics(test_results)

    return test_stats
end

# run_tests(tests::AbstractString) method that converts the argument to a Vector{String}
function run_tests(
    test::AbstractString;
    desc::AbstractString="",
    test_set_type::Union{Type{<:AbstractTestSet},Nothing}=EnhancedTestSet{DefaultTestSet},
    test_set_options::AbstractString="",
    recursive::Bool=true,
)
    # --- Check arguments

    # Ensure that `tests` is not an empty string
    if isempty(test)
        throw(ArgumentError("`test` may not be empty"))
    end

    # --- Run tests

    return run_tests(Vector{String}([test]); desc=desc, test_set_type=test_set_type)
end

"""
    find_tests(dir::AbstractString), <keyword arguments>)::Vector{String}

Construct a list of absolute paths to Julia test files contained in `dir`.

# Keyword Arguments

* `recursive::Bool`: flag indicating whether or not tests found in subdirectories of `dir`
  should be included in results. Default: `true`

* `exclude_runtests::Bool`: flag indicating whether or not to exclude files named
  `runtests.jl` from the list of test files. Default: `true`
"""
function find_tests(
    dir::AbstractString; recursive::Bool=true, exclude_runtests::Bool=true
)::Vector{String}

    # --- Check arguments

    # Ensure `dir` is an absolute path
    dir = abspath(dir)

    # --- Find test files

    # Find test files in `dir`
    files = filter(f -> endswith(f, ".jl"), readdir(dir))
    if exclude_runtests
        files = filter(f -> f != "runtests.jl", files)
    end
    # TODO: filter `tests` to exclude files that do not contain tests

    tests = [joinpath(dir, file) for file in files]

    # Recursively search directories
    if recursive
        dirs = filter(f -> isdir(f), [joinpath(dir, f) for f in readdir(dir)])
        for dir in dirs
            tests = vcat(tests, find_tests(dir; exclude_runtests=exclude_runtests))
        end
    end

    return tests
end
