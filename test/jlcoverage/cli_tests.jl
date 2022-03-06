"""
Unit tests for the methods in `jlcoverage/cli.jl`.

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
using Suppressor

# Local modules
using TestTools.jlcoverage: cli
using TestTools.jltest: TestSetPlus

# --- Tests

@testset TestSetPlus "jlcoverage.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => ".", "verbose" => false, "version" => false)
    @test args == expected_args

    # --- pkg-dir

    # "--pkg-dir"
    raw_args = ["--pkg-dir", "/path/to/pkg"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => raw_args[2], "verbose" => false, "version" => false)
    @test args == expected_args

    # "-d"
    raw_args = ["-d", "/path/to/another/pkg"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => raw_args[2], "verbose" => false, "version" => false)
    @test args == expected_args

    # --- verbose

    # "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => ".", "verbose" => true, "version" => false)
    @test args == expected_args

    # "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => ".", "verbose" => true, "version" => false)
    @test args == expected_args

    # --- version

    # "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => ".", "verbose" => false, "version" => true)
    @test args == expected_args

    # "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("pkg-dir" => ".", "verbose" => false, "version" => true)
    @test args == expected_args
end

@testset TestSetPlus "jlcoverage.cli.run()" begin
    # TODO
end
