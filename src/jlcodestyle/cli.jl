"""
jlcodestyle/cli.jl defines functions for the `jlcodestyle` CLI.

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
using JuliaFormatter

# --- Functions/Methods

"""
    parse_args()

Parse and return command-line arguments passed to the CLI.
"""
function parse_args()::Dict

    # Define command-line arguments
    description = "Check source code files against Julia style conventions."
    arg_table = ArgParse.ArgParseSettings(; description=description)
    ArgParse.@add_arg_table! arg_table begin
        "--overwrite", "-o"
        help = "overwrite files with reformatted source code"
        action = :store_true

        "--style", "-s"
        help = "Julia style convention to apply"
        default = "BlueStyle"

        "--version", "-V"
        help = "show version and exit"
        action = :store_true

        "paths"
        help = "space-separated list of files or directories to apply style conventions to"
        nargs = '*'
    end

    # Parse command-line arguments
    args::Dict = ArgParse.parse_args(ARGS, arg_table)
    args["paths"] = convert(Vector{String}, args["paths"])

    # Set code style
    style_str = args["style"]
    if style_str == "defaultstyle" || style_str == "default"
        args["style"] = DefaultStyle()
    elseif style_str == "yasstyle" || style_str == "yas"
        args["style"] = YASStyle()
    else
        args["style"] = BlueStyle()
    end

    return args
end

"""
    run(paths::Vector{String}; <keyword arguments>)

Run code style checks for files contained in `paths`.

# Keyword Arguments

* `style::JuliaFormatter.AbstractStyle=BlueStyle()`: code style to apply

* `overwrite::Bool=false`: overwrite existing files with style-corrected versions
"""
function run(
    paths::Vector{String};
    style::JuliaFormatter.AbstractStyle=BlueStyle(),
    overwrite::Bool=false,
)

    # --- Preparations

    # Set paths
    if isempty(paths)
        paths = ["."]
    end

    # --- Check code style

    check_passed = format(paths; style=style, overwrite=overwrite, verbose=true)
    if check_passed
        println("\nNo style errors found.")
    else
        if overwrite
            println("\nStyle errors found. Files modified to correct errors.")
        else
            println("\nStyle errors found. Files not modified.")
        end
    end

    return nothing
end
