"""
Unit tests for the methods in `jltest/utils.jl`.

Notes
-----
* For the unit tests in this files, failures and errors are expected.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

# Standard library
using Pkg: Pkg
using Test
using Test: DefaultTestSet

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "jltest.run_tests()" begin
    # --- Preparations

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data")

    # Set up Julia environment
    cwd = pwd()
    cd(test_dir)
    Pkg.instantiate()
    push!(LOAD_PATH, test_dir)
    cd(cwd)

    # Precompute commonly used values
    some_tests_file = joinpath(test_dir, "some_tests.jl")
    expected_output_some_tests = "$(joinpath(test_dir, "some_tests")): .."

    more_tests_file = joinpath(test_dir, "more_tests.jl")
    expected_output_more_tests = "$(joinpath(test_dir, "more_tests")): .."

    failing_tests_file = joinpath(test_dir, "failing_tests.jl")
    expected_output_failing_tests = strip(
        """
        $(joinpath(test_dir, "failing_tests")): .
        =====================================================
        : Test Failed at $(failing_tests_file):18
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
         [1]
        """
    )

    # --- `tests` contains tests named with ".jl" extension

    tests = [some_tests_file]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_some_tests

    # --- `tests` contains tests named without ".jl" extension

    more_tests_file_without_extension = more_tests_file[1:(end - 3)]
    tests = [more_tests_file_without_extension]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_more_tests

    # --- `tests` contains only a directory

    tests = [test_dir]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_more_tests,
        expected_output_failing_tests,
        ": Test Failed at $(failing_tests_file):18",
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    # Check that the "Package TestTools does not have ... in its dependencies" warning
    # has been suppressed
    @test isempty(log_msg)

    # --- `tests` contains both directories and files

    tests = [test_dir, some_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    expected_output_lines = [
        expected_output_more_tests,
        expected_output_failing_tests,
        ": Test Failed at $(failing_tests_file):18\n",
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    output_lines = split(output, '\n')
    @test count(i -> (i == expected_output_some_tests), output_lines) == 2

    # Check that the "Package TestTools does not have ... in its dependencies" warning
    # has been suppressed
    @test isempty(log_msg)

    # --- test keyword arguments

    # name
    tests = [failing_tests_file]
    name = "test-name"
    output = strip(@capture_out begin
        run_tests(tests; name=name)
    end)
    output_line_three = split(strip(output), '\n')[3]
    @test startswith(output_line_three, name)

    # test_set_type
    test_set_type = DefaultTestSet
    tests = [failing_tests_file]
    output = strip(@capture_out begin
        run_tests(tests; test_set_type=test_set_type)
    end)
    expected_prefix =
        "$(joinpath(test_dir, "failing_tests")): " *
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):18"
    @test startswith(output, expected_prefix)

    # --- Clean up

    # Restore LOAD_PATH
    filter!(x -> x != test_dir, LOAD_PATH)

    # Remove Manifest.toml
    rm(joinpath(test_dir, "Manifest.toml"); force=true)
end

@testset TestSetPlus "jltest.autodetect_tests()" begin

    # --- normal operation

    test_dir = joinpath(@__DIR__, "data")
    tests = Set(autodetect_tests(test_dir))
    expected_tests = Set([
        joinpath(test_dir, file) for file in
        ["failing_tests.jl", "missing_deps_tests.jl", "more_tests.jl", "some_tests.jl"]
    ])
    @test tests == expected_tests
end

@testset TestSetPlus "jltest.run_tests(): invalid arguments" begin
    tests = Vector{String}()
    @test_throws ArgumentError run_tests(tests)

    # --- `tests` is empty string

    tests = ""
    @test_throws ArgumentError run_tests(tests)
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 4 failures and 0 errors are expected."
