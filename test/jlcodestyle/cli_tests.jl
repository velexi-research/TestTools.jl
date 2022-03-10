"""
Unit tests for the methods in `jlcodestyle/cli.jl`.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

# Standard library
using Test

# External packages
using JuliaFormatter
using Suppressor

# Local modules
using TestTools.jltest: TestSetPlus
using TestTools.jlcodestyle: cli

# --- Tests

@testset TestSetPlus "jlcodestyle.cli.parse_args()" begin

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

@testset TestSetPlus "jlcodestyle.cli.run()" begin
    # --- Preparations

    # Get current directory
    cwd = pwd()

    # Construct path to test data directory
    test_file_dir = abspath(joinpath(@__DIR__, "data"))

    # --- Exercise functionality and check results

    # Case: `paths` is empty
    cd(test_file_dir)

    output = @capture_out begin
        cli.run([])
    end

    expected_output = """
                      Style errors found. Files not modified.
                      """
    @test output == expected_output

    cd(cwd)  # Restore current directory

    # Case: `paths` contains only source files without style errors
    cd(test_file_dir)

    output = @capture_out begin
        cli.run([joinpath(test_file_dir, "bluestyle-pass.jl")])
    end

    expected_output = """
                      No style errors found.
                      """
    @test output == expected_output

    # Case: verbose = true
    cd(test_file_dir)

    local output
    error = @capture_err begin
        output = @capture_out begin
            cli.run([joinpath(test_file_dir, "bluestyle-pass.jl")]; verbose=true)
        end
    end

    expected_error = """
                     [ Info: Style = BlueStyle
                     [ Info: Overwrite = false
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(joinpath(pwd(), "bluestyle-pass.jl"))

        No style errors found.
        """
    @test output == expected_output

    # Case: `paths` contains only source files without style errors, overwrite = true
    cd(test_file_dir)

    local output
    error = @capture_err begin
        output = @capture_out begin
            cli.run(
                [joinpath(test_file_dir, "bluestyle-pass.jl")]; overwrite=true, verbose=true
            )
        end
    end

    expected_error = """
                     [ Info: Style = BlueStyle
                     [ Info: Overwrite = true
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(joinpath(pwd(), "bluestyle-pass.jl"))

        No style errors found.
        """
    @test output == expected_output

    # Case: `paths` contains only source files with style errors, overwrite = true
    cd(test_file_dir)
    bluestyle_pass_file = joinpath(test_file_dir, "bluestyle-pass.jl")
    yasstyle_fail_file = joinpath(test_file_dir, "yasstyle-fail.jl")
    cp(bluestyle_pass_file, yasstyle_fail_file; force=true)

    local output
    error = @capture_err begin
        output = @capture_out begin
            cli.run(
                [yasstyle_fail_file];
                style=JuliaFormatter.YASStyle(),
                overwrite=true,
                verbose=true,
            )
        end
    end

    expected_error = """
                     [ Info: Style = YASStyle
                     [ Info: Overwrite = true
                     """
    @test error == expected_error

    expected_output = """
        Formatting $(yasstyle_fail_file)

        Style errors found. Files modified to correct errors.
        """
    @test output == expected_output

    rm(yasstyle_fail_file)
end

@testset TestSetPlus "jlcodestyle.cli.run(): invalid arguments" begin

    # Case: invalid `paths` arg
    @test_throws MethodError cli.run([1, 2, 3])
end
