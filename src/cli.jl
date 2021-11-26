"""
TODO
"""
# --- Exports

export jltest, jlcoverage

# --- Imports

# Standard library
using Test

# External packages
using ArgParse
using Documenter

# Local modules
import TestTools

# --- Functions/Methods

"""
TODO
"""
function jltest(; mod::Union{Module,Nothing}=nothing)

    # --- Define CLI

    # Define command-line arguments
    description = "Run unit tests"
    arg_table = ArgParseSettings(; description=description)
    @add_arg_table! arg_table begin
        "--verbose", "-v"
        help = "enable verbose mode"
        action = :store_true

        "--fail-fast", "-x"
        help = "stop testing at first failure"
        action = :store_true

        # TODO: add support for setting module and enabling doctests

        "tests"
        help =
            "Julia test to run. If omitted, all Julia files in the current directory are " *
            "run as tests."
        nargs = '*'
    end

    # Parse command-line arguments
    args = parse_args(ARGS, arg_table)
    verbose = args["verbose"]
    fail_fast = args["fail-fast"]
    tests::Vector{String} = args["tests"]

    # --- Preparations

    # Set `extended_test_set`
    if !fail_fast
        fail_fast = get(ENV, "JULIA_TEST_FAIL_FAST", "false") == "true"
    end
    if fail_fast
        test_set_type = ExtendedTestSet{Test.FallbackTestSet}
    else
        test_set_type = ExtendedTestSet
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
            tests = autodetect_tests(tests)
        end
        run_tests(tests)
    end
end

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
