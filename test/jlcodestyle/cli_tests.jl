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
Unit tests for the methods in `jlcodestyle/cli.jl`.
"""

# --- Imports

# Standard library
using Test

# External packages
using JuliaFormatter
using Suppressor

# Local modules
using TestTools.jltest: EnhancedTestSet
using TestTools.jlcodestyle: cli

# --- Tests

@testset EnhancedTestSet "jlcodestyle.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- overwrite

    # Case: raw_args = "--overwrite"
    raw_args = ["--overwrite"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => true,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-o"
    raw_args = ["-o"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => true,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- style

    # Case: raw_args = "--style"
    raw_args = ["--style", "yas"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => YASStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-s"
    raw_args = ["-s", "default"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => DefaultStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = invalid style
    invalid_style = "InvalidStyle"
    raw_args = ["--style", invalid_style]
    output = @capture_err begin
        args = cli.parse_args(; raw_args=raw_args)
    end
    @test startswith(output, "┌ Warning: Invalid style: $invalid_style. Using BlueStyle")
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- verbose

    # Case: raw_args = "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => true,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => true,
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- version

    # Case: raw_args = "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => true,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Case: raw_args = "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => true,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- paths

    raw_args = ["path/to/file-1.jl", "file-2.jl"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "verbose" => false,
        "version" => false,
        "paths" => raw_args,
    )
    @test args == expected_args
end

@testset EnhancedTestSet "jlcodestyle.cli.run()" begin
    # --- Preparations

    # Local variables
    local check_passed
    local output

    # Get current directory
    cwd = pwd()

    # Construct path to test data directory
    test_file_dir = abspath(joinpath(@__DIR__, "data"))

    # --- Exercise functionality and check results

    # Case: `paths` is empty
    cd(test_file_dir)

    error = @capture_err begin
        check_passed = cli.run([])
    end

    @test !check_passed

    expected_error = """
                     Style errors found. Files not modified.
                     """
    @test error == expected_error

    cd(cwd)  # Restore current directory

    # Case: `paths` contains only source files without style errors
    cd(test_file_dir)

    output = @capture_out begin
        check_passed = cli.run([joinpath(test_file_dir, "blue-style.jl")])
    end

    @test check_passed

    expected_output = """
                      No style errors found.
                      """
    @test output == ""

    # Case: verbose = true
    cd(test_file_dir)

    error = @capture_err begin
        output = @capture_out begin
            check_passed = cli.run([joinpath(test_file_dir, "blue-style.jl")]; verbose=true)
        end
    end

    @test check_passed

    expected_error = """
                     [ Info: Style = BlueStyle
                     [ Info: Overwrite = false
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(joinpath(pwd(), "blue-style.jl"))

        No style errors found.
        """
    @test output == expected_output

    # Case: `paths` contains only source files without style errors, overwrite = true
    cd(test_file_dir)

    error = @capture_err begin
        output = @capture_out begin
            check_passed = cli.run(
                [joinpath(test_file_dir, "blue-style.jl")]; overwrite=true, verbose=true
            )
        end
    end

    @test check_passed

    expected_error = """
                     [ Info: Style = BlueStyle
                     [ Info: Overwrite = true
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(joinpath(pwd(), "blue-style.jl"))

        No style errors found.
        """
    @test output == expected_output

    # Case: `paths` contains only source files with style errors, overwrite = true
    cd(test_file_dir)
    bluestyle_pass_file = joinpath(test_file_dir, "blue-style.jl")
    yasstyle_fail_file = joinpath(test_file_dir, "yasstyle-fail.jl")
    cp(bluestyle_pass_file, yasstyle_fail_file; force=true)
    chmod(yasstyle_fail_file, 0o644)

    error = @capture_err begin
        output = @capture_out begin
            check_passed = cli.run(
                [yasstyle_fail_file];
                style=JuliaFormatter.YASStyle(),
                overwrite=true,
                verbose=true,
            )
        end
    end

    @test !check_passed

    expected_error = """
                     [ Info: Style = YASStyle
                     [ Info: Overwrite = true

                     Style errors found. Files modified to correct errors.
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(yasstyle_fail_file)
        """
    @test output == expected_output

    rm(yasstyle_fail_file)
end

@testset EnhancedTestSet "jlcodestyle.cli.run(): invalid arguments" begin

    # Case: invalid `paths` arg
    @test_throws MethodError cli.run([1, 2, 3])
end
