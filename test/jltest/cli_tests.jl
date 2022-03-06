"""
Unit tests for the methods in `jltest/cli.jl`.

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
using TestTools.jltest: cli, TestSetPlus

# --- Tests

@testset TestSetPlus "jltest.cli.parse_args()" begin

    # --- Default arguments

    raw_args = Vector{String}()
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- fail-fast

    # "--fail-fast"
    raw_args = ["--fail-fast"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => true,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # "-x"
    raw_args = ["-x"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => true,
        "verbose" => false,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- verbose

    # "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => true,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => true,
        "version" => false,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- version

    # "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => false,
        "version" => true,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => false,
        "version" => true,
        "tests" => Vector{String}(),
    )
    @test args == expected_args

    # --- tests

    raw_args = ["test-1", "test-2.jl"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict(
        "fail-fast" => false,
        "verbose" => false,
        "version" => false,
        "tests" => ["test-1", "test-2.jl"],
    )
    @test args == expected_args
end

@testset TestSetPlus "jltest.cli.run()" begin
    # TODO
end

@testset TestSetPlus "jltest.cli.run(): error cases" begin

    # --- Exercise functionality and check results

    @test_throws MethodError cli.run([1, 2, 3])
end
