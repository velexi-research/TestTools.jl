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
Unit tests for the methods in `jltest/utils.jl`.

Notes
-----
* For the unit tests in this files, failures and errors are expected.
"""

# --- Imports

# Standard library
using Logging
using Test
using Test: DefaultTestSet

# External packages
using Coverage: Coverage
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

@testset EnhancedTestSet "jltest.run_tests(): basic tests" begin
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

    failing_tests_no_testset_file = joinpath(test_dir, "failing_tests_no_testset.jl")
    expected_output_failing_tests_no_testset = strip(
        """
        $(joinpath(test_dir_relpath, "failing_tests_no_testset")): .
        =====================================================
        test set: Test Failed at $(failing_tests_no_testset_file):26
          Expression: 2 == 1
           Evaluated: 2 == 1

        Stacktrace:
          [1]
        """
    )

    more_tests_file = joinpath(test_dir, "subdir", "more_tests.jl")
    expected_output_more_tests = "$(joinpath(test_dir_relpath, "subdir", "more_tests")): .."

    # --- Tests for run_tests(tests::Vector{<:AbstractString})

    # `tests` contains tests named with ".jl" extension
    tests = [some_tests_file]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_some_tests

    # `tests` contains tests named without ".jl" extension
    some_tests_no_testset_file_without_extension = some_tests_no_testset_file[1:(end - 3)]
    tests = [some_tests_no_testset_file_without_extension]
    output = strip(@capture_out begin
        run_tests(tests)
    end)
    @test output == expected_output_some_tests_no_testset

    # `tests` contains only a directory
    tests = [test_dir]
    output = strip(@capture_out begin
        run_tests(tests)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
        expected_output_more_tests,
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    # `tests` contains both directories and files
    tests = [test_dir, some_tests_file]
    output = strip(@capture_out begin
        run_tests(tests)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
        expected_output_more_tests,
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end

    output_lines = split(output, '\n')
    @test count(i -> (i == expected_output_some_tests), output_lines) == 2

    # `tests` is empty list
    tests = Vector{String}()
    @test_throws ArgumentError run_tests(tests)

    # --- Tests for run_tests(tests::AbstractString)

    # `tests` is a string
    tests = some_tests_file
    output = strip(@capture_out begin
        run_tests(tests)
    end)

    @test output == expected_output_some_tests

    # `tests` is empty string
    tests = ""
    @test_throws ArgumentError run_tests(tests)

    # --- Keyword arguments tests

    # desc
    tests = [failing_tests_no_testset_file]
    desc = "test description"
    output = strip(@capture_out begin
        run_tests(tests; desc=desc)
    end)
    output_line_three = split(output, '\n')[3]
    @test startswith(output_line_three, desc)

    # test_set_type
    tests = [failing_tests_file]
    output = strip(@capture_out begin
        run_tests(tests; test_set_type=DefaultTestSet)
    end)
    expected_prefix =
        "$(joinpath(test_dir_relpath, "failing_tests")): failing tests" *
        ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):27"
    @test startswith(output, expected_prefix)

    # test_set_type = nothing
    tests = [failing_tests_file]
    output = strip(@capture_out begin
        run_tests(tests; test_set_type=nothing)
    end)
    @test startswith(output, expected_output_failing_tests)

    # recursive = false
    tests = [test_dir]
    output = strip(@capture_out begin
        run_tests(tests; recursive=false)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end
    @test !occursin(expected_output_more_tests, output)

    # exclude_runtests = false
    tests = [test_dir]
    output = strip(@capture_out begin
        run_tests(tests; exclude_runtests=false)
    end)

    expected_output_lines = [
        expected_output_some_tests,
        expected_output_some_tests_no_testset,
        expected_output_failing_tests,
        expected_output_failing_tests_no_testset,
        "$(joinpath(test_dir_relpath, "failing_tests")):",
    ]
    for line in expected_output_lines
        @test occursin(line, output)
    end
end

@testset EnhancedTestSet "jltest.run_tests(): log message tests" begin
    # --- Preparations

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data-log-message-tests")
    test_dir_relpath = relpath(test_dir)

    # Set up Julia environment
    push!(LOAD_PATH, test_dir)

    # Temporarily enable logging at all levels
    env_julia_debug_save = get(ENV, "JULIA_DEBUG", nothing)
    ENV["JULIA_DEBUG"] = "all"

    # Precompute commonly used values
    log_message_tests_file = joinpath(test_dir, "log_message_tests.jl")
    expected_output_log_message_tests = "$(joinpath(test_dir_relpath, "log_message_tests")):"

    location_prefix =
        "TestTools.jltest.##$(joinpath(test_dir_relpath, "log_message_tests"))#[0-9]+ " *
        "$(Base.contractuser(log_message_tests_file))"
    if Sys.iswindows()
        location_prefix = replace(location_prefix, "\\" => "\\\\")
    end

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

    missing_dependencies_tests_file = joinpath(test_dir, "missing_dependencies_tests.jl")
    expected_output_missing_dependencies_tests = "$(joinpath(test_dir_relpath, "missing_dependencies_tests")):"
    expected_log_messages_missing_dependencies_tests = "[ Info: Non-missing dependency log message"

    # --- Tests

    local output

    # Case: "Package TestTools does not have ... in its dependencies" warning suppressed
    tests = [missing_dependencies_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)
    @test output == expected_output_missing_dependencies_tests
    @test occursin(expected_log_messages_missing_dependencies_tests, log_msg)

    # Case: only non-missing dependency log messages
    tests = [log_message_tests_file]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    @test output == expected_output_log_message_tests

    for message in expected_log_messages_log_message_tests
        @test occursin(message, log_msg)
    end

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

@testset EnhancedTestSet "jltest.run_tests(): current directory checks" begin
    # --- Preparations

    # Get current directory
    cwd = pwd()

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data-directory-change-tests")

    # Change to test directory
    cd(test_dir)

    # Precompute commonly used values
    change_dir_file = joinpath(test_dir, "change_dir.jl")
    expected_output_change_dir = "$(relpath(joinpath(test_dir, "change_dir"), test_dir)): "

    # Delete old coverage data files
    @suppress begin
        Coverage.clean_folder(test_dir)
    end

    # --- Tests

    # Case: change directory before running test file
    check_dir_file = joinpath(test_dir, "check_dir.jl")
    tests = [change_dir_file, check_dir_file]
    output = strip(@capture_out begin
        run_tests(tests)
    end)

    expected_output = join(
        [
            expected_output_change_dir,
            "$(relpath(joinpath(test_dir, "check_dir"), test_dir)): .",
        ],
        '\n',
    )
    @test output == expected_output

    # Case: change directory before running tests in a directory
    tests = [change_dir_file, joinpath(test_dir, "subdir")]
    output = strip(@capture_out begin
        run_tests(tests)
    end)

    expected_output = join(
        [
            expected_output_change_dir,
            "$(relpath(joinpath(test_dir, "subdir", "check_dir"), test_dir)): .",
        ],
        '\n',
    )
    @test output == expected_output

    # --- Clean up

    # Restore current directory
    cd(cwd)
end

@testset EnhancedTestSet "jltest.run_tests(): JLTEST_FAIL_FAST tests" begin
    # --- Preparations

    # Construct path to test directory
    test_dir = joinpath(@__DIR__, "data-basic-tests")
    test_dir_relpath = relpath(test_dir)

    # Save original value of JLTEST_FAIL_FAST environment variable
    env_jltest_fail_fast_original = get(ENV, "JLTEST_FAIL_FAST", nothing)

    # Precompute commonly used values
    some_tests_file = joinpath(test_dir, "some_tests.jl")
    expected_output_some_tests = "$(joinpath(test_dir_relpath, "some_tests")): .."

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

    more_tests_file = joinpath(test_dir, "subdir", "more_tests.jl")
    expected_output_more_tests = "$(joinpath(test_dir_relpath, "subdir", "more_tests")): .."

    # --- Tests

    # Case: ENV["JLTEST_FAIL_FAST"] = false
    ENV["JLTEST_FAIL_FAST"] = false
    tests = [failing_tests_file, some_tests_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            jltest.run_tests(tests)
        catch error
        end
    end)

    if isnothing(env_jltest_fail_fast_original)  # Restore ENV["JLTEST_FAIL_FAST"]
        delete!(ENV, "JLTEST_FAIL_FAST")
    else
        ENV["JLTEST_FAIL_FAST"] = env_jltest_fail_fast_original
    end

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests, output)
    @test isnothing(error)

    # Case: ENV["JLTEST_FAIL_FAST"] is undefined
    # Expect: same behavior as ENV["JLTEST_FAIL_FAST"] = false
    delete!(ENV, "JLTEST_FAIL_FAST")
    tests = [failing_tests_file, some_tests_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            jltest.run_tests(tests)
        catch error
        end
    end)

    if isnothing(env_jltest_fail_fast_original)  # Restore ENV["JLTEST_FAIL_FAST"]
        delete!(ENV, "JLTEST_FAIL_FAST")
    else
        ENV["JLTEST_FAIL_FAST"] = env_jltest_fail_fast_original
    end

    @test startswith(output, expected_output_failing_tests)
    @test occursin(expected_output_some_tests, output)
    @test isnothing(error)

    # Case: ENV["JLTEST_FAIL_FAST"] = true
    ENV["JLTEST_FAIL_FAST"] = "true"
    tests = [failing_tests_file, some_tests_file]
    local error = nothing
    output = strip(@capture_out begin
        try
            jltest.run_tests(tests)
        catch error
        end
    end)

    if isnothing(env_jltest_fail_fast_original)  # Restore ENV["JLTEST_FAIL_FAST"]
        delete!(ENV, "JLTEST_FAIL_FAST")
    else
        ENV["JLTEST_FAIL_FAST"] = env_jltest_fail_fast_original
    end

    @test startswith(output, expected_output_failing_tests_fail_fast)
    @test !occursin(expected_output_some_tests, output)
    @test error isa Test.FallbackTestSetException
    @test error.msg == "There was an error during testing"
end

@testset EnhancedTestSet "jltest.find_tests()" begin

    # --- directory without subdirectories

    test_dir = joinpath(@__DIR__, "data-find-tests", "subdir")
    tests = Set(find_tests(test_dir))
    expected_tests = Set([joinpath(test_dir, "more_tests.jl")])
    @test tests == expected_tests

    # --- directory with subdirectories

    test_dir = joinpath(@__DIR__, "data-find-tests")
    tests = Set(find_tests(test_dir))
    expected_tests = Set([
        joinpath(test_dir, file) for
        file in ["some_tests.jl", joinpath("subdir", "more_tests.jl")]
    ])
    @test tests == expected_tests

    # --- Keyword arguments tests

    # recursive = false
    test_dir = joinpath(@__DIR__, "data-find-tests")
    tests = Set(find_tests(test_dir; recursive=false))
    expected_tests = Set([joinpath(test_dir, "some_tests.jl")])
    @test tests == expected_tests

    # exclude_runtests = false
    test_dir = joinpath(@__DIR__, "data-find-tests")
    tests = Set(find_tests(test_dir; exclude_runtests=false))
    expected_tests = Set([
        joinpath(test_dir, file) for file in [
            "runtests.jl",
            "some_tests.jl",
            joinpath("subdir", "more_tests.jl"),
            joinpath("subdir", "runtests.jl"),
        ]
    ])
    @test tests == expected_tests
end

@testset EnhancedTestSet "jltest: Pkg.test() tests" begin
    # --- Preparations

    # Get current directory
    cwd = pwd()

    test_pkg_dir = joinpath(@__DIR__, "data-missing-package-dependency", "TestPackage")
    cmd_options = `--startup-file=no --project=@. -O0`
    cmd = `julia $(cmd_options) -e 'import Pkg; Pkg.test(coverage=true)'`

    # --- Tests

    test_error = strip(@capture_out begin
        try
            @suppress_err begin
                Base.run(Cmd(cmd; dir=test_pkg_dir); wait=true)
            end
        catch process_error
            @test process_error isa ProcessFailedException
        end
    end)

    src_error_file = abspath(
        joinpath(dirname(dirname(@__DIR__)), "src", "jltest", "utils.jl")
    )
    test_error_file = joinpath(test_pkg_dir, "test", "missing_dependency_tests.jl")
    expected_test_error = strip(
        """
        missing_dependency_tests: 
        =====================================================
        test set: Error During Test at $(src_error_file):285
          Got exception outside of a @test
          The test environment is missing InteractiveUtils from its dependencies.
          Error occurred at $(test_error_file):22
          Stacktrace:
            [1]
        """
    )
    @test startswith(test_error, expected_test_error)

    # --- Clean up

    # Remove Manifest.toml
    rm(joinpath(test_pkg_dir, "Manifest.toml"); force=true)
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 13 failures and 0 errors are expected."
