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
cli.jl defines the `jltest.cli` module containing functions for the `jltest` CLI.

Notes
-----
* CLI functions are defined in a .jl file so that testing and code quality tools can by
  applied to the CLI source code.
"""
module cli

# --- Exports

export parse_args, run

# --- Imports

# Standard library
using Test

# External packages
using ArgParse: ArgParse

# Local modules
using ..jltest

# --- Functions/Methods

"""
    parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

Parse and return CLI arguments contained in `raw_args`. By default, `raw_args` is set to
`ARGS`, the command-line arguments provided to the executable that called `parse_args()`.
"""
function parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

    # Define the command-line interface
    description = "Run unit tests"
    arg_table = ArgParse.ArgParseSettings(; prog="jltest", description=description)
    ArgParse.@add_arg_table! arg_table begin
        "--fail-fast", "-x"
        help = "stop testing at first failure"
        action = :store_true

        "--verbose", "-v"
        help = "display more output to the console"
        action = :store_true

        "--version", "-V"
        help = "show version and exit"
        action = :store_true

        "tests"
        help =
            "tests to run. Any directories present in `tests` are searched " *
            "(recursively) for tests to run. If `tests` is omitted, the current " *
            "directory is searched (recursively) for tests to run."
        nargs = '*'
    end

    # Parse command-line arguments
    args = ArgParse.parse_args(raw_args, arg_table)
    args["tests"] = convert(Vector{String}, args["tests"])

    return args
end

"""
    run(tests::Vector; <keyword arguments>)

Run unit tests defined in the list of files or modules provided in `tests`.

# Keyword Arguments

* `name::AbstractString`: name to use for test set used to group `tests`.
    Default: `"All tests"

* `fail_fast::Bool`: stop testing at first failure. Default: `false`

* `verbose::Bool`: print more output to the console. Default: `false`
"""
function run(
    tests::Vector;
    name::AbstractString="All tests",
    fail_fast::Bool=false,
    verbose::Bool=false,
)
    # --- Check arguments

    # Ensure that `tests` contains strings
    tests = convert(Vector{String}, tests)

    # --- Preparations

    # Set test set type
    if !fail_fast
        fail_fast = get(ENV, "JLTEST_FAIL_FAST", "false") == "true"
    end
    if fail_fast
        test_set_type = EnhancedTestSet{Test.FallbackTestSet}
    else
        test_set_type = EnhancedTestSet
    end

    # Set test options
    # TODO: figure out how to pass verbose option to @testset when the test set type
    #       is explicitly specified
    #test_set_options = ""
    #if verbose
    #    test_set_options *= "verbose=true"
    #end

    # --- Run tests

    # Unit tests
    if length(tests) == 0
        tests = find_tests(pwd())
    end
    run_tests(tests; name=name, test_set_type=test_set_type)

    return nothing
end

end  # End of jltest.cli module
