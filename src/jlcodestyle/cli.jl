"""
TODO
"""
# --- Exports

export jlcodestyle

# --- Imports

# External packages
using ArgParse
using JuliaFormatter

# --- Functions/Methods

"""
TODO
"""
function jlcodestyle()

    # --- Define CLI

    # Define command-line arguments
    description = "Check source code files against Julia style conventions."
    arg_table = ArgParseSettings(; description=description)
    @add_arg_table! arg_table begin
        "--overwrite", "-o"
        help = "overwrite files with reformatted source code"
        action = :store_true

        "--style", "-s"
        help = "Julia style convention to apply"
        default = "BlueStyle"

        "paths"
        help = "space-separated list of files or directories to apply style conventions to"
        nargs = '*'
    end

    # Parse command-line arguments
    args::Dict = parse_args(ARGS, arg_table)
    overwrite::Bool = args["overwrite"]
    style_str::String = lowercase(args["style"])
    paths::Vector{String} = args["paths"]

    # --- Preparations

    # Set paths
    if isempty(paths)
        paths = ["."]
    end

    # Set code style
    if style_str == "defaultstyle" || style_str == "default"
        style = DefaultStyle()
    elseif style_str == "yasstyle" || style_str == "yas"
        style = YASStyle()
    else
        style = BlueStyle()
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
