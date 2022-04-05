#   Copyright (c) 2022 Velexi Corporation
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
Unit tests for the methods in `jltest/cli.jl`.

Notes
-----
* For the unit tests in this files, failures and errors are expected.
"""

# --- Imports

# Standard library
using Test

# External packages
using Suppressor

# Local modules
using TestTools.jltest: cli, EnhancedTestSet

# --- Tests

@testset EnhancedTestSet "jltest.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- fail-fast

    # Case: raw_args = "--fail-fast"
    raw_args = ["--fail-fast"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => true,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-x"
    raw_args = ["-x"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => true,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- no-wrapper

    # Case: raw_args = "--no-wrapper"
    raw_args = ["--no-wrapper"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => true,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-W"
    raw_args = ["-W"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => true,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- no-recursion

    # Case: raw_args = "--no-recursion"
    raw_args = ["--no-recursion"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => true,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-R"
    raw_args = ["-R"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => true,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- verbose

    # Case: raw_args = "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => true,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => true,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- version

    # Case: raw_args = "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => true,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => true,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- tests

    raw_args = ["test-1", "test-2.jl"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "no-wrapper" => false,
        "no-recursion" => false,
        "verbose" => false,
        "version" => false,
        "tests" => ["test-1", "test-2.jl"],
    )
    @test args == expected_args
end

@testset EnhancedTestSet "jltest.cli.run(): basic tests" begin
    # --- Preparations

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data-basic-tests")
    test_dir_relpath = relpath(test_dir)

    # Precompute commonly used values
    some_tests_file = joinpath(test_dir, "some_tests.jl")
    expected_output_some_tests = "$(joinpath(test_dir_relpath, "some_tests")): .."

    some_tests_no_testset_file = joinpath(test_dir, "some_tests_no_testset.jl")
    expected_output_some_tests_no_testset = "$(joinpath(test_dir_relpath, "some_tests_no_testset")): .."

    failing_tests_file = joinpath(test_dir, "failing_tests.jl")
    expected_output_failing_tests = strip(
        """
        $(joinpath(test_dir_relpath, "failing_tests")): .
        =====================================================
        failing tests: Test Failed at $(failing_tests_file):27
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
         [1]
        """
    )

    expected_output_failing_tests_fail_fast = strip(
        """
        $(joinpath(test_dir_relpath, "failing_tests")): .
        =====================================================
        Test Failed at $(failing_tests_file):27
          Expression: 2 == 1
           Evaluated: 2 == 1

        =====================================================
        Error During Test at
        """
    )

    failing_tests_no_testset_file = joinpath(test_dir, "failing_tests_no_testset.jl")
    expected_output_failing_tests_no_testset = strip(
        """
        $(joinpath(test_dir_relpath, "failing_tests_no_testset")): .
        =====================================================
        All tests: Test Failed at $(failing_tests_no_testset_file):26
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
          [1]
        """
    )

    more_tests_file = joinpath(test_dir, "subdir", "more_tests.jl")
    expected_output_more_tests = "$(joinpath(test_dir_relpath, "subdir", "more_tests")): .."

    # --- Tests

    # Case: normal operation
    tests = [some_tests_file, some_tests_no_testset_file]
    output = strip(@capture_out begin
        cli.run(tests)
    end)

    @test occursin(expected_output_some_tests, output)
    @test occursin(expected_output_some_tests_no_testset, output)

    # Case: fail_fast = true
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; fail_fast=true)
        catch error
        end
    end)

    @test error isa Test.FallbackTestSetException
    @test error.msg == "There was an error during testing"

    @test startswith(output, expected_output_failing_tests_fail_fast)
    @test !occursin("some_tests_no_testset", output)

    # Case: use_wrapper = false, fail_fast = true
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; fail_fast=true, use_wrapper=false)
        catch error
        end
    end)

    @test error isa Test.FallbackTestSetException
    @test error.msg == "There was an error during testing"

    @test startswith(output, expected_output_failing_tests_fail_fast)
    @test !occursin("some_tests_no_testset", output)

    # Case: use_wrapper = false, fail_fast = false
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; use_wrapper=false)
        catch error
        end
    end)

    @test isnothing(error)

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests_no_testset, output)

    # Case: recursive = false
    tests = [test_dir]
    local error = nothing
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            try
                cli.run(tests; recursive=false)
            catch error
            end
        end)
    end)

    @test isnothing(error)

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_failing_tests_no_testset, output)
    @test occursin(expected_output_some_tests, output)
    @test occursin(expected_output_some_tests_no_testset, output)
    @test !occursin("more_tests", output)

    # Case: `tests` is empty
    cd(test_dir)
    tests = []
    local error = nothing
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            try
                cli.run(tests)
            catch error
            end
        end)
    end)

    @test isnothing(error)

    expected_output_failing_tests = strip(
        """
        failing_tests: .
        =====================================================
        failing tests: Test Failed at $(failing_tests_file):27
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
         [1]
        """
    )
    @test startswith(output, expected_output_failing_tests)

    expected_output_failing_tests_no_testset = strip(
        """
        failing_tests_no_testset: .
        =====================================================
        All tests: Test Failed at $(failing_tests_no_testset_file):26
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
          [1]
        """
    )
    @test occursin(expected_output_failing_tests_no_testset, output)

    expected_output_some_tests = "some_tests: .."
    @test occursin(expected_output_some_tests, output)

    expected_output_some_tests_no_testset = "some_tests_no_testset: .."
    @test occursin(expected_output_some_tests_no_testset, output)

    expected_output_more_tests = "$(joinpath("subdir", "more_tests")): .."
    @test occursin(expected_output_more_tests, output)
end

@testset EnhancedTestSet "jltest.cli.run(): error cases" begin

    # --- Exercise functionality and check results

    # Case: invalid `tests` arg
    @test_throws MethodError cli.run([1, 2, 3])
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 5 failures and 0 errors are expected."
