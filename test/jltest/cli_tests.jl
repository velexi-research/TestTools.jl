"""
Unit tests for the methods in `jltest/cli.jl`.

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

# External packages
using Suppressor

# Local modules
using TestTools.jltest: cli, TestSetPlus

# --- Tests

@testset TestSetPlus "jltest.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
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
        "verbose" => false,
        "version" => false,
        "tests" => ["test-1", "test-2.jl"],
    )
    @test args == expected_args
end

@testset TestSetPlus "jltest.cli.run()" begin
    # --- Preparations

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data")

    # Set up Julia environment
    push!(LOAD_PATH, test_dir)

    # Temporarily enable logging at all levels
    env_julia_debug_save = get(ENV, "JULIA_DEBUG", nothing)
    ENV["JULIA_DEBUG"] = "all"

    # Precompute commonly used values
    some_tests_file = joinpath(test_dir, "some_tests.jl")
    expected_output_some_tests = "$(joinpath(test_dir, "some_tests")): .."

    some_tests_no_testset_file = joinpath(test_dir, "some_tests_no_testset.jl")
    expected_output_some_tests_no_testset = "$(joinpath(test_dir, "some_tests_no_testset")): .."

    failing_tests_file = joinpath(test_dir, "failing_tests.jl")
    expected_output_failing_tests = strip(
        """
        $(joinpath(test_dir, "failing_tests")): .
        =====================================================
        failing tests: Test Failed at $(failing_tests_file):19
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
         [1]
        """
    )

    expected_output_failing_tests_fail_fast = strip(
        """
        $(joinpath(test_dir, "failing_tests")): .
        =====================================================
        Test Failed at $(failing_tests_file):19
          Expression: 2 == 1
           Evaluated: 2 == 1

        =====================================================
        Error During Test at
        """
    )

    log_message_tests_file = joinpath(test_dir, "log_message_tests.jl")
    expected_output_log_message_tests = "$(joinpath(test_dir, "log_message_tests")):"

    location_prefix =
        "TestTools.jltest.##$(joinpath(test_dir, "log_message_tests"))#[0-9]+ " *
        "$(Base.contractuser(log_message_tests_file))"
    expected_log_messages_log_message_tests = [
        "[ Warning: Single line @warn message test",
        Regex(strip("""
                    ┌ Warning: Multi-line @warn message test.
                    │ Second line.
                    │ Third line.
                    └ @ $(location_prefix):[0-9]+
                    """)),
        "[ Info: Single line @info message test",
        strip("""
              ┌ Info: Multi-line @info message test.
              │ Second line.
              └ Third line.
              """),
        "[ Debug: Single line @debug message test",
        Regex(strip("""
                    ┌ Debug: Multi-line @debug message test.
                    │ Second line.
                    │ Third line.
                    └ @ $(location_prefix):[0-9]+
                    """)),
    ]

    missing_deps_tests_file = joinpath(test_dir, "missing_deps_tests.jl")
    expected_output_missing_deps_tests = "$(joinpath(test_dir, "missing_deps_tests")):"
    expected_log_messages_missing_deps_tests = "[ Info: Non-missing dependency log message"

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

    @test startswith(output, expected_output_failing_tests_fail_fast)
    @test !occursin(expected_output_some_tests_no_testset, output)
    @test error isa Test.FallbackTestSetException
    @test error.msg == "There was an error during testing"

    # Case: fail_fast = false, ENV["JLTEST_FAIL_FAST"] = true
    ENV["JLTEST_FAIL_FAST"] = "true"
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; fail_fast=false)
        catch error
        end
    end)

    @test startswith(output, expected_output_failing_tests_fail_fast)
    @test !occursin(expected_output_some_tests_no_testset, output)
    @test error isa Test.FallbackTestSetException
    @test error.msg == "There was an error during testing"

    # Case: fail_fast = false, ENV["JLTEST_FAIL_FAST"] = false
    ENV["JLTEST_FAIL_FAST"] = false
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; fail_fast=false)
        catch error
        end
    end)

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests_no_testset, output)
    @test isnothing(error)

    # Case: fail_fast = false, ENV["JLTEST_FAIL_FAST"] undefined
    delete!(ENV, "JLTEST_FAIL_FAST")
    tests = [failing_tests_file, some_tests_no_testset_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            cli.run(tests; fail_fast=false)
        catch error
        end
    end)

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests_no_testset, output)
    @test isnothing(error)

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

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests, output)
    @test occursin(expected_output_some_tests_no_testset, output)
    @test isnothing(error)

    # Check log messages
    for message in expected_log_messages_log_message_tests
        @test occursin(message, log_msg)
    end
    @test occursin(expected_log_messages_missing_deps_tests, log_msg)

    # --- Clean up

    # Remove Manifest.toml
    rm(joinpath(test_dir, "Manifest.toml"); force=true)

    # Restore LOAD_PATH
    filter!(x -> x != test_dir, LOAD_PATH)

    # Restore state of ENV
    if isnothing(env_julia_debug_save)
        delete!(ENV, "JULIA_DEBUG")
    else
        ENV["JULIA_DEBUG"] = env_julia_debug_save
    end
end

@testset TestSetPlus "jltest.cli.run(): error cases" begin

    # --- Exercise functionality and check results

    # Case: invalid `tests` arg
    @test_throws MethodError cli.run([1, 2, 3])
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 4 failures and 0 errors are expected."
