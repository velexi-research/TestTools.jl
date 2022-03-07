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
using Test
using Test: DefaultTestSet

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "jltest.run_tests()" begin
    # --- Preparations

    test_dir = joinpath(dirname(@__FILE__), "utils_tests-data")

    # --- `tests` is an empty list

    tests = Vector{String}()
    @test_throws ArgumentError run_tests(tests)

    # --- `tests` is empty string

    tests = ""
    @test_throws ArgumentError run_tests(tests)

    # --- `tests` contains tests named with ".jl" extension

    tests = [joinpath(test_dir, "some_tests.jl")]
    output = @capture_out begin
        run_tests(tests)
    end
    expected_output = "$(joinpath(test_dir, "some_tests")): .."
    @test strip(output) == expected_output

    # --- `tests` contains tests named without ".jl" extension

    tests = [joinpath(test_dir, "more_tests")]
    output = @capture_out begin
        run_tests(tests)
    end
    expected_output = "$(joinpath(test_dir, "more_tests")): .."
    @test strip(output) == expected_output

    # --- `tests` contains only a directory

    tests = [test_dir]
    output = @capture_out begin
        run_tests(tests)
    end
    output_lines = split(strip(output), '\n')
    expected_output_lines = [
        "$(joinpath(test_dir, "more_tests")): ..",
        "$(joinpath(test_dir, "some_tests")): ..",
        "$(joinpath(test_dir, "failing_tests")): .",
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):18",
    ]
    for line in expected_output_lines
        @test line in output_lines
    end

    # --- `tests` contains both directories and files

    tests = [test_dir, joinpath(test_dir, "some_tests.jl")]
    output = @capture_out begin
        run_tests(tests)
    end
    output_lines = split(strip(output), '\n')
    expected_output_lines = [
        "$(joinpath(test_dir, "more_tests")): ..",
        "$(joinpath(test_dir, "failing_tests")): .",
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):18",
    ]
    for line in expected_output_lines
        @test line in output_lines
    end
    expected_line = "$(joinpath(test_dir, "some_tests")): .."
    @test count(i -> (i == expected_line), output_lines) == 2

    # --- test keyword arguments

    # name
    tests = [joinpath(test_dir, "failing_tests.jl")]
    name = "test-name"
    output = @capture_out begin
        run_tests(tests; name=name)
    end
    output_line_three = split(strip(output), '\n')[3]
    @test startswith(output_line_three, name)

    # test_set_type
    test_set_type = DefaultTestSet
    tests = [joinpath(test_dir, "failing_tests.jl")]
    output = @capture_out begin
        run_tests(tests; test_set_type=test_set_type)
    end
    prefix =
        "$(joinpath(test_dir, "failing_tests")): " *
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):18"
    @test startswith(strip(output), prefix)
end

@testset TestSetPlus "jltest.autodetect_tests()" begin

    # --- normal operation

    test_dir = joinpath(dirname(@__FILE__), "utils_tests-data")
    tests = autodetect_tests(test_dir)
    expected_tests = ["failing_tests.jl", "more_tests.jl", "some_tests.jl"]
    for test_file in expected_tests
        @test joinpath(test_dir, test_file) in tests
    end
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 4 failures and 0 errors are expected."
