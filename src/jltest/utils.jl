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
import Pkg
using Test
using Test: AbstractTestSet

# External packages
using OrderedCollections: OrderedDict
using Suppressor: @capture_err, @suppress_err

# --- Private utility functions

"""
    emit_log_msg(messages::AbstractString)

Remove missing dependency warnings from log messages and reemit them.
"""
function emit_log_msg(messages::AbstractString)

    # --- No-op if `messages` is empty

    if isempty(messages)
        return
    end

    # --- Preparations

    # Get lines of message
    lines = split(messages, '\n')

    # --- Extract, reformat, and re-emit messages

    message_finished = true
    message_lines = nothing
    for i in 1:length(lines)

        # --- Extract next log message

        if message_finished
            message_lines = [lines[i]]

            # Check for multi-line message
            if startswith(lines[i], "┌ ")
                message_finished = false
            end

        else
            push!(message_lines, lines[i])

            # Check for end of multi-line message
            if startswith(lines[i], "└ ")
                message_finished = true
            end
        end

        if message_finished

            # --- Skip missing dependency warning

            if occursin(
                r"^┌ Warning: Package TestTools does not have \S* in its dependencies:",
                message_lines[1],
            )
                continue
            end

            # --- Preparations

            # Get log level
            log_level = Logging.Warn
            if occursin("Info", message_lines[1])
                log_level = Logging.Info
            elseif occursin("Debug", message_lines[1])
                log_level = Logging.Debug
            end

            # --- Reformat message

            # Reformat first line
            if startswith(message_lines[1], "┌ Warning: ")
                message_lines[1] = replace(message_lines[1], "┌ Warning: " => "")
            elseif startswith(message_lines[1], "[ Warning: ")
                message_lines[1] = replace(message_lines[1], "[ Warning: " => "")
            elseif startswith(message_lines[1], "┌ Info: ")
                message_lines[1] = replace(message_lines[1], "┌ Info: " => "")
            elseif startswith(message_lines[1], "[ Info: ")
                message_lines[1] = replace(message_lines[1], "[ Info: " => "")
            elseif startswith(message_lines[1], "┌ Debug: ")
                message_lines[1] = replace(message_lines[1], "┌ Debug: " => "")
            elseif startswith(message_lines[1], "[ Debug: ")
                message_lines[1] = replace(message_lines[1], "[ Debug: " => "")
            end

            # Reformat middle lines
            for i in 2:(length(message_lines) - 1)
                message_lines[i] = replace(message_lines[i], "│ " => "")
            end

            # Reformat last line of message
            message_lines[end] = replace(message_lines[end], "└ " => "")

            # --- Emit message

            message = join(message_lines, '\n')
            @logmsg log_level message _module = nothing _file = nothing _group = nothing
        end
    end
end

"""
    handle_test_exception(error::Base.error)

Handle exception thrown when running a test file. If `error` is a missing package
dependency, construct a LoadError to throw outside of the catch block. Otherwise, rethrow
the error.
"""
function handle_test_exception(error::Exception)
    if error isa LoadError && error.error isa ArgumentError
        match_results = match(
            r".*Package TestTools does not have (.*?) in its dependencies:.*",
            error.error.msg,
        )

        if !isnothing(match_results)
            message = strip(
                """
                The test environment is missing $(match_results[1]) from its dependencies.
                Error occurred at $(error.file):$(error.line)
                """
            )
            return ErrorException(message)
        end
    end

    # Not a missing dependency error, so rethrow it.
    rethrow()

    return nothing
end

"""
    run_all_tests(test_files::Vector{<:AbstractString})

Run all tests contained in `test_files`.
"""
function run_all_tests(pkg::Module, test_files::Vector{<:AbstractString})

    # Get current directory
    cwd = pwd()

    # Run tests files
    if !isempty(test_files)
        for test_file in test_files
            # Restore current directory before each test file is run
            cd(cwd)

            # Construct module name
            module_name = splitext(relpath(test_file, cwd))[1]

            # Run test, capturing log messages
            println()
            print(module_name, ": ")
            mod = gensym(module_name)
            missing_dependency_error = nothing
            log_msg = strip(@capture_err begin
                try
                    #@eval module $mod
                    #Base.include($mod, abspath($test_file))
                    #end
                    #@eval module $pkg
                    Base.include(Main, abspath(test_file))
                    #end
                catch error
                    missing_dependency_error = handle_test_exception(error)
                end
            end)

            if !isnothing(missing_dependency_error)
                throw(missing_dependency_error)
            end

            emit_log_msg(log_msg)
        end
    end
end

# --- Functions/Methods

"""
    run_tests(tests::Vector; <keyword arguments>)
    run_tests(tests::AbstractString; <keyword arguments>)

Run tests in the list of files or modules provided in `tests`. If `tests` is an empty list
or an empty string, an `ArgumentError` is thrown. File names in `tests` may be specified
with or without the `.jl` extension.

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

* `recursive::Bool`: flag indicating whether or not to run tests found in subdirectories
  of directories in `tests`. Default: `true`

* `exclude_runtests::Bool`: flag indicating whether or not to exclude files named
  `runtests.jl` from the list of test files that are run. Default: `true`
"""
function run_tests(
    pkg::Module,
    tests::Vector;
    desc::AbstractString="",
    test_set_type::Union{Type{<:AbstractTestSet},Nothing}=EnhancedTestSet{DefaultTestSet},
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
        run_all_tests(pkg, test_files)
    else
        if isempty(desc)
            @testset test_set_type begin
                run_all_tests(pkg, test_files)
            end
        else
            @testset test_set_type "$desc" begin
                run_all_tests(pkg, test_files)
            end
        end
    end

    return nothing
end

# run_tests(tests::AbstractString) method that converts the argument to a Vector{String}
function run_tests(
    pkg::Module,
    test::AbstractString;
    desc::AbstractString="",
    test_set_type::Union{Type{<:AbstractTestSet},Nothing}=EnhancedTestSet{DefaultTestSet},
    recursive::Bool=true,
)
    # --- Check arguments

    # Ensure that `tests` is not an empty string
    if isempty(test)
        throw(ArgumentError("`test` may not be empty"))
    end

    # --- Run tests

    run_tests(pkg, Vector{String}([test]); desc=desc, test_set_type=test_set_type)

    return nothing
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
