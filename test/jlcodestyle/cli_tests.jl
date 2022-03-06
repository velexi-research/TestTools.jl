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
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- overwrite

    # "--overwrite"
    raw_args = ["--overwrite"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => true,
        "style" => BlueStyle(),
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # "-o"
    raw_args = ["-o"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => true,
        "style" => BlueStyle(),
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- style

    # "--style"
    raw_args = ["--style", "yas"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => YASStyle(),
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # "-s"
    raw_args = ["-s", "default"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => DefaultStyle(),
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # Invalid style
    invalid_style = "InvalidStyle"
    raw_args = ["--style", invalid_style]
    output = @capture_err begin
        args = cli.parse_args(; raw_args=raw_args)
    end
    @test startswith(output, "┌ Warning: Invalid style: $invalid_style. Using BlueStyle")
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "version" => false,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # --- version

    # "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
        "version" => true,
        "paths" => Vector{String}(),
    )
    @test args == expected_args

    # "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "overwrite" => false,
        "style" => BlueStyle(),
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
        "version" => false,
        "paths" => raw_args,
    )
    @test args == expected_args
end

@testset TestSetPlus "jlcodestyle.cli.run()" begin
    # TODO
end
