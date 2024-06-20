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
cli.jl defines the `jlcoverage.cli` module containing functions for the `jlcoverage` CLI.

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
using Logging

# External packages
using ArgParse
using Coverage
using CoverageTools

# Local modules
using ..jlcoverage

# --- Functions/Methods

"""
    parse_args(; raw_args::Vector{<:AbstractString}=ARGS) -> Dict

Parse and return CLI arguments contained in `raw_args`. By default, `raw_args` is set to
`ARGS`, the command-line arguments provided to the executable that called `parse_args()`.

Return Values
=============
* parsed CLI arguments converted to Julia types
"""
function parse_args(; raw_args::Vector{<:AbstractString}=ARGS)

    # Define command-line arguments
    description = "Generate coverage analysis report."
    arg_table = ArgParse.ArgParseSettings(; prog="jlcoverage", description=description)
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
    run(paths::Vector; kwargs...)

Run code coverage analysis for files and directories in `paths`.

Keyword Arguments
=================
* `verbose::Bool`: print more output to the console. Default: `false`
"""
function run(paths::Vector; verbose::Bool=false)
    # --- Check arguments

    # Ensure that `paths` contains strings
    paths = convert(Vector{String}, paths)

    # --- Preparations

    # Handle edge case
    if isempty(paths)
        if isfile("Project.toml") && isdir("src")
            @info "Detected Julia package. Generating report for files in `src` directory."
            paths = ["src"]
        else
            message =
                "Julia package not detected. Generating report for files in current " *
                "directory."
            @info message
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
