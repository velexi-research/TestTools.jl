"""
TODO
"""
# --- Exports

export jlcoverage

# --- Imports

# External packages
using ArgParse

# --- Functions/Methods

"""
TODO
"""
function jlcoverage()

    # --- Define CLI

    # Define command-line arguments
    description = "Generate coverage analysis report."
    arg_table = ArgParseSettings(; description=description)
    @add_arg_table! arg_table begin
        "--keep-cov-files", "-k"
        help = "retain *.cov files"
        action = :store_true

        "--pkg-dir", "-d"
        help = "package directory"
        default = "."

        "--verbose", "-v"
        help = "enable verbose mode"
        action = :store_true
    end

    # Parse command-line arguments
    args::Dict = parse_args(ARGS, arg_table)
    keep_cov_files::Bool = args["keep-cov-files"]
    pkg_dir::String = args["pkg-dir"]
    verbose::Bool = args["verbose"]

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
