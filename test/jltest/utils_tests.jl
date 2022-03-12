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
using Logging
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

    failing_tests_no_testset_file = joinpath(test_dir, "failing_tests_no_testset.jl")
    expected_output_failing_tests_no_testset = strip(
        """
        $(joinpath(test_dir, "failing_tests_no_testset")): .
        =====================================================
        : Test Failed at $(failing_tests_no_testset_file):18
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
         [1]
        """
    )

    log_message_tests_file = joinpath(test_dir, "log_message_tests.jl")
    expected_output_log_message_tests = "$(joinpath(test_dir, "log_message_tests")):"

    location_prefix =
        "TestTools.jltest.##$(joinpath(test_dir, "log_message_tests"))#[0-9]+ " *
        "$(Base.contractuser(log_message_tests_file))"
    expected_log_messages_log_message_tests = [
        Regex(strip("""
                    ┌ Warning: Single line @warn message test
                    └ @ $(location_prefix):19
                    """)),
        Regex(strip("""
                    ┌ Warning: Multi-line @warn message test.
                    │ Second line.
                    │ Third line.
                    └ @ $(location_prefix):20
                    """)),
        strip("""
              [ Info: Single line @info message test
              ┌ Info: Multi-line @info message test.
              │ Second line.
              └ Third line.
              """),
        Regex(strip("""
                    ┌ Debug: Single line @debug message test
                    └ @ $(location_prefix):36
                    """)),
        Regex(strip("""
                    ┌ Debug: Multi-line @debug message test.
                    │ Second line.
                    │ Third line.
                    └ @ $(location_prefix):37
                    """)),
    ]

    missing_deps_tests_file = joinpath(test_dir, "missing_deps_tests.jl")
    expected_output_missing_deps_tests = "$(joinpath(test_dir, "missing_deps_tests")):"
    expected_log_messages_missing_deps_tests = "[ Info: Non-missing dependency log message"

    # --- `tests` contains tests named with ".jl" extension

    tests = [some_tests_file]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_some_tests

    # --- `tests` contains tests named without ".jl" extension

    some_tests_no_testset_file_without_extension = some_tests_no_testset_file[1:(end - 3)]
    tests = [some_tests_no_testset_file_without_extension]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_some_tests_no_testset

    # --- `tests` contains only a directory

    tests = [test_dir]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
        expected_output_log_message_tests,
        expected_output_missing_deps_tests,
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    # Check log messages
    for message in expected_log_messages_log_message_tests
        @test occursin(message, log_msg)
    end
    @test occursin(expected_log_messages_missing_deps_tests, log_msg)

    # --- `tests` contains both directories and files

    tests = [test_dir, some_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
        expected_output_log_message_tests,
        expected_output_missing_deps_tests,
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    output_lines = split(output, '\n')
    @test count(i -> (i == expected_output_some_tests), output_lines) == 2

    # Check log messages
    for message in expected_log_messages_log_message_tests
        @test occursin(message, log_msg)
    end
    @test occursin(expected_log_messages_missing_deps_tests, log_msg)

    # --- test log message handling

    # ------ Case: "Package TestTools does not have ... in its dependencies" warning
    #              suppressed

    tests = [missing_deps_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)
    @test output == expected_output_missing_deps_tests
    @test occursin(expected_log_messages_missing_deps_tests, log_msg)

    # ------ Case: only non-missing dependency log messages

    tests = [log_message_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    @test output == expected_output_log_message_tests

    # Check log messages
    for message in expected_log_messages_log_message_tests
        @test occursin(message, log_msg)
    end

    # --- test keyword arguments

    # name
    tests = [failing_tests_no_testset_file]
    name = "test-name"
    output = strip(@capture_out begin
        run_tests(tests; name=name)
    end)
    output_line_three = split(output, '\n')[3]
    @test startswith(output_line_three, name)

    # test_set_type
    test_set_type = DefaultTestSet
    tests = [failing_tests_file]
    output = strip(@capture_out begin
        run_tests(tests; test_set_type=test_set_type)
    end)
    expected_prefix =
        "$(joinpath(test_dir, "failing_tests")): failing tests" *
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):19"
    @test startswith(output, expected_prefix)

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

@testset TestSetPlus "jltest.autodetect_tests()" begin

    # --- normal operation

    test_dir = joinpath(@__DIR__, "data")
    tests = Set(autodetect_tests(test_dir))
    expected_tests = Set([
        joinpath(test_dir, file) for file in [
            "failing_tests.jl",
            "failing_tests_no_testset.jl",
            "log_message_tests.jl",
            "missing_deps_tests.jl",
            "some_tests.jl",
            "some_tests_no_testset.jl",
        ]
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
@info "For $(basename(@__FILE__)), 6 failures and 0 errors are expected."
