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

# --- Helper functions

function make_windows_safe_regex(s::AbstractString)
    if Sys.iswindows()
        s = replace(s, "\\" => "\\\\")
    end

    return s
end

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
    expected_output_failing_tests = Regex(
        make_windows_safe_regex(strip("""
                            $(joinpath(test_dir_relpath, "failing_tests")): .
                            =====================================================
                            failing tests: Test Failed at $(failing_tests_file):[0-9]+
                              Expression: 2 == 1
                               Evaluated: 2 == 1
                            """))
    )

    failing_tests_no_testset_file = joinpath(test_dir, "failing_tests_no_testset.jl")
    expected_output_failing_tests_no_testset = Regex(
        make_windows_safe_regex(
            strip("""
                  $(joinpath(test_dir_relpath, "failing_tests_no_testset")): .
                  =====================================================
                  test set: Test Failed at $(failing_tests_no_testset_file):[0-9]+
                    Expression: 2 == 1
                     Evaluated: 2 == 1
                  """)
        ),
    )

    more_tests_file = joinpath(test_dir, "subdir", "more_tests.jl")
    expected_output_more_tests = "$(joinpath(test_dir_relpath, "subdir", "more_tests")): .."

    # --- Tests for run_tests(tests::Vector{<:AbstractString})

    # `tests` contains tests named with ".jl" extension
    tests = [some_tests_file]
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)
    @test output == expected_output_some_tests

    # `tests` contains tests named without ".jl" extension
    some_tests_no_testset_file_without_extension = some_tests_no_testset_file[1:(end - 3)]
    tests = [some_tests_no_testset_file_without_extension]
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)
    @test output == expected_output_some_tests_no_testset

    # `tests` contains only a directory
    tests = [test_dir]
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 8, :fail => 2, :error => 0, :broken => 0)

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
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests)
    end)

    # Note: if the file appears in `tests` multiple times, its test statistics are counted
    #       multiple times
    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 10, :fail => 2, :error => 0, :broken => 0)

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
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)
    @test output == expected_output_some_tests

    # `tests` is empty string
    tests = ""
    @test_throws ArgumentError run_tests(tests)

    # --- Keyword argument tests

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
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests; test_set_type=DefaultTestSet)
    end)
    expected_prefix = Regex(
        make_windows_safe_regex(
            strip(
                "$(joinpath(test_dir_relpath, "failing_tests")): failing tests" *
                ": Test Failed at $(joinpath(test_dir, "failing_tests.jl")):[0-9]+",
            ),
        ),
    )

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 1, :fail => 1, :error => 0, :broken => 0)

    @test startswith(output, expected_prefix)

    # test_set_type = nothing
    tests = [failing_tests_file]
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests; test_set_type=nothing)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 0, :fail => 0, :error => 0, :broken => 0)

    @test startswith(output, expected_output_failing_tests)

    # recursive = false
    tests = [test_dir]
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests; recursive=false)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 6, :fail => 2, :error => 0, :broken => 0)

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
    local test_stats = nothing
    output = strip(@capture_out begin
        test_stats = run_tests(tests; exclude_runtests=false)
    end)

    @test test_stats isa Dict
    @test keys(test_stats) == Set([:pass, :fail, :error, :broken])
    @test test_stats == Dict(:pass => 8, :fail => 2, :error => 0, :broken => 0)

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

    # test_set_options = Dict(:verbose => true)
    # Note: this case is tested in `verbose_mode_tests.jl`
end

@testset EnhancedTestSet "jltest.run_tests(): log message tests" begin
    # --- Preparations

    # Set up temporary directory for testing
    tmp_dir = mktempdir()
    test_dir = joinpath(tmp_dir, "data-log-message-tests")
    cp(joinpath(@__DIR__, "data-log-message-tests"), test_dir)

    # Construct path to test directory
    test_dir_relpath = relpath(test_dir)

    # Set up Julia environment
    push!(LOAD_PATH, test_dir)

    # Temporarily enable logging at all levels
    env_julia_debug_save = get(ENV, "JULIA_DEBUG", nothing)
    ENV["JULIA_DEBUG"] = "all"

    # --- Tests

    # ------ Case: "Package TestTools does not have ... in its dependencies" warning
    #        suppressed

    local output = ""
    local log_msg = ""
    tests = [joinpath(test_dir, "missing_dependencies_tests.jl")]
    log_msg = strip(@capture_err begin
        output = strip(@capture_out begin
            run_tests(tests)
        end)
    end)

    expected_output_missing_dependencies_tests = "$(joinpath(test_dir_relpath, "missing_dependencies_tests")):"
    @test output == expected_output_missing_dependencies_tests

    expected_log_messages_missing_dependencies_tests = "[ Info: Log message that isn't about a missing dependency"
    @test occursin(expected_log_messages_missing_dependencies_tests, log_msg)

    # ------ Case: only non-missing dependency log messages

    log_message_tests_file = joinpath(test_dir, "log_message_tests.jl")
    expected_output_log_message_tests = "$(joinpath(test_dir_relpath, "log_message_tests")):"

    test_path = joinpath(test_dir_relpath, "log_message_tests")
    if VERSION < v"1.8-"
        location_prefix = "Main.##$(test_path)#[0-9]+ $(abspath(log_message_tests_file))"
    else
        test_path = make_windows_safe_regex(test_path)
        location_prefix = "Main.var\"##$(test_path)#[0-9]+\" $(abspath(log_message_tests_file))"
    end
    location_prefix = make_windows_safe_regex(location_prefix)

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

    local output = ""
    local log_msg = ""
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
    expected_output_failing_tests = Regex(
        make_windows_safe_regex(strip("""
                            $(joinpath(test_dir_relpath, "failing_tests")): .
                            =====================================================
                            failing tests: Test Failed at $(failing_tests_file):[0-9]+
                              Expression: 2 == 1
                               Evaluated: 2 == 1
                            """))
    )

    expected_output_failing_tests_fail_fast_prefix = Regex(
        make_windows_safe_regex(strip("""
                            $(joinpath(test_dir_relpath, "failing_tests")): .
                            =====================================================
                            Test Failed at $(failing_tests_file):[0-9]+
                              Expression: 2 == 1
                               Evaluated: 2 == 1
                            """))
    )

    expected_output_failing_tests_fail_fast_interior = Regex(
        make_windows_safe_regex(strip("""
                            =====================================================
                            Error During Test at
                            """))
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

    @test occursin(r"^" * expected_output_failing_tests, output)
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

    @test startswith(output, expected_output_failing_tests_fail_fast_prefix)
    @test occursin(expected_output_failing_tests_fail_fast_interior, output)
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

    # --- Keyword argument tests

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

    # Set up temporary directory for testing
    tmp_dir = mktempdir()
    test_pkg_dir = joinpath(tmp_dir, "TestPackage")
    cp(joinpath(@__DIR__, "data-missing-package-dependency", "TestPackage"), test_pkg_dir)

    # Create system command to run test
    cmd_options = `--startup-file=no --project=@. -O0`
    cmd = Cmd(
        `julia $(cmd_options) -e 'import Pkg; Pkg.test(coverage=true)'`; dir=test_pkg_dir
    )

    # Add path to TestTools.jl package to use for testing
    test_tools_src_dir = abspath(@__DIR__, "..", "..")
    cmd = addenv(cmd, Dict("JLTEST_LOAD_PATH" => "$test_tools_src_dir"))

    # --- Tests

    src_error_file = abspath(
        joinpath(dirname(dirname(@__DIR__)), "src", "jltest", "utils.jl")
    )
    expected_test_error = Regex(
        make_windows_safe_regex(
            strip(
                """
                missing_dependency_tests: 
                =====================================================
                test set: Error During Test at $(src_error_file):[0-9]+
                  Got exception outside of a @test
                  LoadError: ArgumentError: Package InteractiveUtils not found in current path.
                """,
            ),
        ),
    )

    local test_error = ""
    if VERSION < v"1.8-"
        test_error = strip(@capture_out begin
            try
                @suppress_err begin
                    Base.run(cmd; wait=true)
                end
            catch process_error
                @test process_error isa ProcessFailedException
            end
        end)

        @test startswith(test_error, expected_test_error)
    else
        test_error = strip(@capture_err begin
            try
                Base.run(cmd; wait=true)
            catch process_error
                @test process_error isa ProcessFailedException
            end
        end)

        @test occursin(expected_test_error, test_error)
    end
end

@testset EnhancedTestSet "jltest.get_test_statistics()" begin
    # --- Preparations

    test_dir = joinpath(@__DIR__, "data-basic-tests")
    tests = [joinpath(test_dir, "some_tests_no_testset.jl")]

    # --- Exercise functionality and check results

    # test_set = EnhancedTestSet{DefaultTestSet}
    local stats = nothing
    @suppress_out begin
        stats = run_tests(tests; test_set_type=EnhancedTestSet{DefaultTestSet})
    end
    expected_stats = Dict(:fail => 0, :pass => 2, :error => 0, :broken => 0)
    @test stats == expected_stats

    # test_set = DefaultTestSet
    local stats = nothing
    @suppress_out begin
        stats = run_tests(tests; test_set_type=DefaultTestSet)
    end
    expected_stats = Dict(:fail => 0, :pass => 2, :error => 0, :broken => 0)
    @test stats == expected_stats

    # test_set = EnhancedTestSet{Test.FallbackTestSet}
    test_set = EnhancedTestSet{Test.FallbackTestSet}("description")
    expected_stats = Dict(:pass => 0, :fail => 0, :error => 0, :broken => 0)
    stats = jltest.get_test_statistics(test_set)
    @test stats == expected_stats

    # test_set = nothing
    test_set = nothing
    expected_stats = Dict(:pass => 0, :fail => 0, :error => 0, :broken => 0)
    stats = jltest.get_test_statistics(test_set)
    @test stats == expected_stats
end

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 13 failures and 0 errors are expected."
