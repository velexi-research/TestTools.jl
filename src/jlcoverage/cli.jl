"""
cli.jl defines the `jlcoverage.cli` module containing functions for the `jlcoverage` CLI.

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
module cli

# --- Exports

export parse_args, run

# --- Imports

# Standard library
using Logging

# External packages
using ArgParse: ArgParse
using Coverage

# --- Functions/Methods

"""
    parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

Parse and return CLI arguments contained in `raw_args`. By default, `raw_args` is set to
`ARGS`, the command-line arguments provided to the executable that called `parse_args()`.
"""
function parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

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
    args::Dict = ArgParse.parse_args(raw_args, arg_table)

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

    # --- Process coverage data and display results

    # Process `*.cov` files in `src_dir`
    coverage = Coverage.process_folder(src_dir::String)

    # Display coverage results
    display_coverage(coverage)

    return nothing
end

end  # End of jlcoverage.cli module
