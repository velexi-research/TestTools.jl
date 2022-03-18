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
cli.jl defines the `jlcodestyle.cli` module containing functions for the `jlcodestyle` CLI.

Notes
-----
* CLI functions are defined in a .jl file so that testing and code quality tools can by
  applied to the CLI source code.
"""
module cli

# --- Exports

export parse_args, run

# --- Imports

# External packages
using ArgParse: ArgParse
using JuliaFormatter

# Local modules
using ..jlcodestyle

# --- Functions/Methods

"""
    parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

Parse and return CLI arguments contained in `raw_args`. By default, `raw_args` is set to
`ARGS`, the command-line arguments provided to the executable that called `parse_args()`.
"""
function parse_args(; raw_args::Vector{<:AbstractString}=ARGS)::Dict

    # Define command-line arguments
    description = "Check source code files against Julia style conventions."
    arg_table = ArgParse.ArgParseSettings(; description=description)
    ArgParse.@add_arg_table! arg_table begin
        "--overwrite", "-o"
        help = "overwrite files with reformatted source code"
        action = :store_true

        "--style", "-s"
        help = "Julia style convention to apply. Supported styles: blue, yas, default"
        default = "blue"

        "--verbose", "-v"
        help = "display more output to the console"
        action = :store_true

        "--version", "-V"
        help = "show version and exit"
        action = :store_true

        "paths"
        help = "space-separated list of files or directories to apply style conventions to"
        nargs = '*'
    end

    # Parse command-line arguments
    args::Dict = ArgParse.parse_args(raw_args, arg_table)
    args["paths"] = convert(Vector{String}, args["paths"])

    # Set code style
    style_str = lowercase(args["style"])
    if style_str == "default" || style_str == "defaultstyle"
        args["style"] = DefaultStyle()
    elseif style_str == "yas" || style_str == "yasstyle"
        args["style"] = YASStyle()
    else
        if !(style_str == "blue" || style_str == "bluestyle")
            style = args["style"]
            message = "Invalid style: $(style). Using BlueStyle."
            @warn message
        end

        args["style"] = BlueStyle()
    end

    return args
end

"""
    run(paths::Vector; <keyword arguments>)

Run code style checks for files contained in `paths`.

# Keyword Arguments

* `style::JuliaFormatter.AbstractStyle`: code style to apply.
    Default: `BlueStyle()`

* `overwrite::Bool`: overwrite existing files with style-corrected versions.
    Default: `false`

* `verbose::Bool`: print more output to the console. Default: `false`
"""
function run(
    paths::Vector;
    style::JuliaFormatter.AbstractStyle=BlueStyle(),
    overwrite::Bool=false,
    verbose::Bool=false,
)
    # --- Check arguments

    # Ensure that `paths` contains strings
    paths = convert(Vector{String}, paths)

    # --- Preparations

    # Set paths
    if isempty(paths)
        paths = ["."]
    end

    # --- Emit messages

    if verbose
        style_name = split("$(typeof(style))", '.')[2]
        @info "Style = $(style_name)"

        @info "Overwrite = $(overwrite)"
    end

    # --- Check code style

    check_passed = format(paths; style=style, overwrite=overwrite, verbose=verbose)

    if verbose
        println()
    end

    if check_passed
        println("No style errors found.")
    else
        if overwrite
            println("Style errors found. Files modified to correct errors.")
        else
            println("Style errors found. Files not modified.")
        end
    end

    return nothing
end

end  # End of jlcodestyle.cli module
