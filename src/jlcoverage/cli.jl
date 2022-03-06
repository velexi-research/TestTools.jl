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
using ArgParse
using Coverage
using CoverageTools

# Local modules
using ..jlcoverage

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
        "--verbose", "-v"
        help = "enable verbose mode"
        action = :store_true

        "--version", "-V"
        help = "show version and exit"
        action = :store_true

        "paths"
        help =
            "files and directories to include coverage analysis. If `paths` is empty, " *
            "a coverage report is generated for all Julia source files contained in " *
            "(1) the `src` directory if the current directory is a Julia package " *
            "(i.e., the current directory contains `Project.toml` and `src`) or " *
            "(2) the current directory if it is not a Julia package."
        nargs = '*'
    end

    # Parse command-line arguments
    args::Dict = ArgParse.parse_args(raw_args, arg_table)
    args["paths"] = convert(Vector{String}, args["paths"])

    return args
end

"""
    run(paths::Vector{<:AbstractString}; <keyword arguments>)

Run code coverage analysis for files and directories in `paths`.

# Keyword Arguments

* `verbose::Bool=false`: print more output to the console
"""
function run(paths::Vector{<:AbstractString}; verbose::Bool=false)
    # --- Preparations

    # Handle edge case
    if isempty(paths)
        if isfile("Project.toml") && isdir("src")
            @info("Detected Julia package. Generating report for files in `src` directory.")
            paths = ["src"]
        else
            message =
                "Julia package not detected. Generating report for files in current " *
                "directory."
            @info(message)
            paths = ["."]
        end
    end

    # Set log level
    if !verbose
        disable_logging(Logging.Info)
    end

    # --- Process coverage data and display results

    # Process `*.cov` files
    coverage = Vector{CoverageTools.FileCoverage}()
    for path in paths
        # Ensure paths are absolute paths
        if !isabspath(path)
            path = abspath(path)
        end

        # Process coverage files
        if isdir(path)
            coverage = CoverageTools.merge_coverage_counts(
                coverage, Coverage.process_folder(path::String)
            )
        elseif isfile(path)
            coverage = CoverageTools.merge_coverage_counts(
                coverage, [Coverage.process_file(path)]
            )
        else
            @warn "$path not found. Skipping..."
            continue
        end
    end

    # Display coverage results
    display_coverage(coverage)

    return nothing
end

end  # End of jlcoverage.cli module
