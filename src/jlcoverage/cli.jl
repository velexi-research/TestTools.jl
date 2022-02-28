"""
jlcoverage/cli.jl defines functions for the `jlcoverage` CLI.

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

# External packages
using ArgParse: ArgParse

# --- Functions/Methods

"""
    parse_args()

Parse and return command-line arguments passed to the CLI.
"""
function parse_args()::Dict

    # Define command-line arguments
    description = "Generate coverage analysis report."
    arg_table = ArgParse.ArgParseSettings(; description=description)
    ArgParse.@add_arg_table! arg_table begin
        "--pkg-dir", "-d"
        help = "package directory"
        default = "."

        "--verbose", "-v"
        help = "enable verbose mode"
        action = :store_true

        "--version", "-V"
        help = "show version and exit"
        action = :store_true
    end

    # Parse command-line arguments
    args::Dict = ArgParse.parse_args(ARGS, arg_table)

    return args
end

"""
    run(pkg_dir::AbstractString; <keyword arguments>)

Run code coverage analysis for the Julia project in `pkg_dir`.

# Keyword Arguments

* `verbose::Bool=false`: print more output to the console
"""
function run(pkg_dir::AbstractString; verbose::Bool=false)

    # --- Preparations

    # Set log level
    if !verbose
        disable_logging(Logging.Info)
    end

    # Construct paths to src and test directories
    src_dir = joinpath(pkg_dir, "src")
    test_dir = joinpath(pkg_dir, "test")

    # --- Analyze code coverage and display results

    coverage = analyze_coverage(src_dir::String, test_dir::String)
    display_results(coverage)

    return nothing
end
