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

@testset TestSetPlus "TestSetPlus: run_tests()" begin
    # --- Preparations

    dir = dirname(@__FILE__)

    # --- test is named with ".jl" extension

    tests = [joinpath(dir, "utils_tests", "some_tests.jl")]
    output = @capture_out begin
        run_tests(tests)
    end
    expected_output = "$(joinpath(dir, "utils_tests", "some_tests")): .."
    @test strip(output) == expected_output

    # --- test is named without ".jl" extension

    tests = [joinpath(dir, "utils_tests", "more_tests")]
    output = @capture_out begin
        run_tests(tests)
    end
    expected_output = "$(joinpath(dir, "utils_tests", "more_tests")): .."
    @test strip(output) == expected_output

    # --- test contains only a directory

    tests = [joinpath(dir, "utils_tests")]
    output = @capture_out begin
        run_tests(tests)
    end
    output_lines = split(strip(output), '\n')
    expected_output_lines = [
        "$(joinpath(dir, "utils_tests", "more_tests")): ..",
        "$(joinpath(dir, "utils_tests", "some_tests")): ..",
        "$(joinpath(dir, "utils_tests", "failing_tests")): .",
        ": Test Failed at $(joinpath(dir, "utils_tests", "failing_tests.jl")):18",
    ]
    for line in expected_output_lines
        @test line in output_lines
    end

    # --- test contains both directories and files

    tests = [joinpath(dir, "utils_tests"), joinpath(dir, "utils_tests", "some_tests.jl")]
    output = @capture_out begin
        run_tests(tests)
    end
    output_lines = split(strip(output), '\n')
    expected_output_lines = [
        "$(joinpath(dir, "utils_tests", "more_tests")): ..",
        "$(joinpath(dir, "utils_tests", "failing_tests")): .",
        ": Test Failed at $(joinpath(dir, "utils_tests", "failing_tests.jl")):18",
    ]
    for line in expected_output_lines
        @test line in output_lines
    end
    expected_line = "$(joinpath(dir, "utils_tests", "some_tests")): .."
    @test count(i -> (i == expected_line), output_lines) == 2

    # --- test keyword arguments

    # name
    tests = [joinpath(dir, "utils_tests", "failing_tests.jl")]
    name = "test-name"
    output = @capture_out begin
        run_tests(tests; name=name)
    end
    output_line_three = split(strip(output), '\n')[3]
    @test startswith(output_line_three, name)

    # test_set_type
    test_set_type = DefaultTestSet
    tests = [joinpath(dir, "utils_tests", "failing_tests.jl")]
    output = @capture_out begin
        run_tests(tests; test_set_type=test_set_type)
    end
    prefix =
        "$(joinpath(dir, "utils_tests", "failing_tests")): " *
        ": Test Failed at $(joinpath(dir, "utils_tests", "failing_tests.jl")):18"
    @test startswith(strip(output), prefix)

    # mod
    # TODO
end

@testset TestSetPlus "TestSetPlus: autodetect_tests()" begin
    # normal operation
    dir = dirname(@__FILE__)
    tests = autodetect_tests(dir)
    expected_tests = [
        "TestSetPlus_fail_fast_tests.jl",
        "TestSetPlus_passing_tests.jl",
        "TestSetPlus_failing_tests.jl",
        "utils_tests.jl",
    ]
    for test_file in expected_tests
        @test joinpath(dir, test_file) in tests
    end

    # directory containing "runtests.jl"
    dir = dirname(dirname(@__FILE__))
    tests = autodetect_tests(dir)
    @test tests == []
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 4 failures and 0 errors are expected."
