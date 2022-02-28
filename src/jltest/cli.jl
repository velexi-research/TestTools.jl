"""
jltest/cli.jl defines functions for the `jltest` CLI.

Notes
-----
* CLI functions are defined in a .jl file so that testing and code quality tools can by
  applied to the CLI source code.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""

# --- Exports

export parse_args, run

# --- Imports

# Standard library
using Test

# External packages
using ArgParse: ArgParse

# --- Functions/Methods

"""
    parse_args()

Parse and return command-line arguments passed to the CLI.
"""
function parse_args()::Dict

    # Define the command-line interface
    description = "Run unit tests"
    arg_table = ArgParse.ArgParseSettings(; description=description)
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
            "Julia test to run. If omitted, all Julia files in the current directory " *
            "are run as tests."
        nargs = '*'

        # TODO: add support for setting module and enabling doctests
    end

    # Parse command-line arguments
    args = ArgParse.parse_args(ARGS, arg_table)
    args["tests"] = convert(Vector{String}, args["tests"])

    return args
end

"""
    run(tests::Vector{String}; <keyword arguments>)

Run unit tests defined in the list of files or modules provided in `tests`.

# Keyword Arguments

* `mod::Union{Module,Nothing}=nothing`: module to run doctests for

* `fail_fast::Bool=false`: stop testing at first failure

* `verbose::Bool=false`: print more output to the console
"""
function run(
    tests::Vector{String};
    mod::Union{Module,Nothing}=nothing,
    fail_fast::Bool=false,
    verbose::Bool=false,
)
    # --- Preparations

    # Set TestSet type
    if !fail_fast
        fail_fast = get(ENV, "JULIA_TEST_FAIL_FAST", "false") == "true"
    end
    if fail_fast
        test_set_type = TestSetPlus{Test.FallbackTestSet}
    else
        test_set_type = TestSetPlus
    end

    # Set test options
    testset_options = ""
    if verbose
        testset_options *= "verbose=true"
    end

    # --- Run tests

    #TODO: figure out how to make this work
    #@testset "Doctests" begin
    #    doctest(mod)
    #end

    @testset testset_options test_set_type "Unit tests" begin
        if length(tests) == 0
            tests = autodetect_tests()
        end
        run_tests(tests)
    end
end
