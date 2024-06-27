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
Unit tests for the methods in `jlcoverage/cli.jl`.
"""

# --- Imports

# Standard library
using Logging: Logging
using Test

# External packages
using Coverage: Coverage
using Suppressor

# Local modules
using TestTools.jlcoverage: cli
using TestTools.jltest: EnhancedTestSet

# --- Tests

@testset EnhancedTestSet "jlcoverage.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "verbose" => false, "version" => false, "paths" => Vector{String}()
    )
    @test args == expected_args

    # --- verbose

    # Case: raw_args = "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => Vector{String}())
    @test args == expected_args

    # Case: raw_args = "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => Vector{String}())
    @test args == expected_args

    # --- version

    # Case: raw_args = "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => true, "paths" => Vector{String}())
    @test args == expected_args

    # Case: raw_args = "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => true, "paths" => Vector{String}())
    @test args == expected_args

    # --- paths

    # Case: normal usage
    raw_args = ["/path/to/file-1.jl", "/path/to/dir"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => false, "paths" => raw_args)
    @test args == expected_args

    # Case: `paths` contains "."
    raw_args = ["."]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => false, "paths" => raw_args)
    @test args == expected_args

    # --- Mixed arguments

    # Case: normal usage
    raw_args = ["-v", "/path/to/file-1.jl", "/path/to/dir"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => raw_args[2:3])
    @test args == expected_args
end

@testset EnhancedTestSet "jlcoverage.cli.run(): normal operation" begin

    # --- Preparations

    # Get current directory
    cwd = pwd()

    # Set up temporary directory for testing
    tmp_dir = mktempdir()
    test_pkg_dir = joinpath(tmp_dir, "TestPackage")
    cp(joinpath(@__DIR__, "data", "TestPackage"), test_pkg_dir)

    # Generate coverage data for TestPackage
    cmd_options = `--startup-file=no --project=. -O0`
    cmd = Cmd(
        `julia $(cmd_options) -e 'import Pkg; Pkg.test(coverage=true)'`; dir=test_pkg_dir
    )
    @suppress begin
        Base.run(cmd; wait=true)
    end

    # --- Exercise functionality and check results

    # Case: `paths` contains a single directory, verbose=false
    cd(test_pkg_dir)

    output = @capture_out begin
        cli.run([test_pkg_dir])
    end

    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
$(joinpath("src", "TestPackage.jl"))                                        1         0    100.0%
$(joinpath("src", "methods.jl"))                                            3         1     66.7%
$(joinpath("src", "more_methods.jl"))                                       2         2      0.0%
$(joinpath("test", "runtests.jl"))                                          0         0       N/A
--------------------------------------------------------------------------------
TOTAL                                                     6         3     50.0%
"""
    @test output == expected_output

    cd(cwd)  # Restore current directory

    # Case: `paths` contains a single directory, verbose=true
    # TODO: add test to check that log messages are generated
    cd(test_pkg_dir)

    output = @capture_out begin
        cli.run([test_pkg_dir]; verbose=true)
    end

    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
$(joinpath("src", "TestPackage.jl"))                                        1         0    100.0%
$(joinpath("src", "methods.jl"))                                            3         1     66.7%
$(joinpath("src", "more_methods.jl"))                                       2         2      0.0%
$(joinpath("test", "runtests.jl"))                                          0         0       N/A
--------------------------------------------------------------------------------
TOTAL                                                     6         3     50.0%
"""
    @test output == expected_output

    cd(cwd)  # Restore current directory

    # Case: `paths` contains a file
    cd(test_pkg_dir)

    src_file = joinpath("src", "methods.jl")
    output = @capture_out begin
        cli.run([src_file])
    end

    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
$(joinpath("src", "methods.jl"))                                            3         1     66.7%
--------------------------------------------------------------------------------
TOTAL                                                     3         1     66.7%
"""
    @test output == expected_output

    cd(cwd)  # Restore current directory

    # Case: `paths` is empty and current directory is a Julia package
    cd(test_pkg_dir)

    output = @capture_out begin
        cli.run([])
    end

    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
$(joinpath("src", "TestPackage.jl"))                                        1         0    100.0%
$(joinpath("src", "methods.jl"))                                            3         1     66.7%
$(joinpath("src", "more_methods.jl"))                                       2         2      0.0%
--------------------------------------------------------------------------------
TOTAL                                                     6         3     50.0%
"""
    @test output == expected_output

    cd(cwd)  # Restore current directory

    # Case: `paths` is empty and current directory is not a Julia package
    cd(joinpath(test_pkg_dir, "src"))

    output = @capture_out begin
        cli.run([])
    end
    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
TestPackage.jl                                            1         0    100.0%
methods.jl                                                3         1     66.7%
more_methods.jl                                           2         2      0.0%
--------------------------------------------------------------------------------
TOTAL                                                     6         3     50.0%
"""
    @test output == expected_output

    cd(cwd)  # Restore current directory
end

@testset EnhancedTestSet "jlcoverage.cli.run(): error cases" begin

    # --- Exercise functionality and check results

    # Case: invalid `paths` argument
    @test_throws MethodError cli.run([1, 2, 3])

    # Case: `paths` contains an invalid path
    invalid_file = joinpath("path", "to", "invalid", "file")
    local output
    error = @capture_err begin
        output = @capture_out begin
            cli.run([invalid_file])
        end
    end
    expected_error = "┌ Warning: $(joinpath(pwd(), invalid_file)) not found. Skipping..."
    @test startswith(error, expected_error)

    expected_output = """
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
TOTAL                                                     0         0       N/A
"""
    @test output == expected_output
end

# Re-enable logging to avoid interfering with other unit tests.
#
# Note: setting the log level less than the log level for Logging.Debug ensures that
#       log messages at all levels are displayed
Logging.disable_logging(Logging.LogLevel(Logging.Debug.level - 1))
