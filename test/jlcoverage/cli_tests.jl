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
    expected_args = Dict(
        "verbose" => false, "version" => false, "paths" => Vector{String}()
    )
    @test args == expected_args

    # --- verbose

    # "--verbose"
    raw_args = ["--verbose"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => Vector{String}())
    @test args == expected_args

    # "-v"
    raw_args = ["-v"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => Vector{String}())
    @test args == expected_args

    # --- version

    # "--version"
    raw_args = ["--version"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => true, "paths" => Vector{String}())
    @test args == expected_args

    # "-V"
    raw_args = ["-V"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => true, "paths" => Vector{String}())
    @test args == expected_args

    # --- paths

    # Normal usage
    raw_args = ["/path/to/file-1.jl", "/path/to/dir"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => false, "paths" => raw_args)
    @test args == expected_args

    # `paths` contains "."
    raw_args = ["."]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => false, "version" => false, "paths" => raw_args)
    @test args == expected_args

    # --- Mixed arguments

    # Normal usage
    raw_args = ["-v", "/path/to/file-1.jl", "/path/to/dir"]
    args = cli.parse_args(; raw_args=raw_args)
    expected_args = Dict("verbose" => true, "version" => false, "paths" => raw_args[2:3])
    @test args == expected_args
end

@testset TestSetPlus "jlcoverage.cli.run()" begin

    # --- Preparations

    # Get current directory
    cur_dir = pwd()

    # Generate coverage data for TestPackage
    test_pkg_dir = joinpath(dirname(@__FILE__), "utils_tests-test_package", "TestPackage")
    cmd = `julia --startup-file=no --project=@. -e 'import Pkg; Pkg.test(coverage=true)'`
    @suppress begin
        Base.run(Cmd(cmd; dir=test_pkg_dir); wait=true)
    end

    # --- Exercise functionality and check results

    # `paths` contains a single directory, verbose=false
    cd(joinpath(test_pkg_dir))
    output = @capture_out begin
        cli.run([test_pkg_dir])
    end
    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
src/TestPackage.jl                                1          0     100.0%
src/methods.jl                                    3          1      66.7%
src/more_methods.jl                               2          2       0.0%
test/runtests.jl                                  0          0        N/A
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cur_dir)  # Restore current directory

    # `paths` contains a single directory, verbose=false
    # TODO: add test to check that log messages are generated
    cd(joinpath(test_pkg_dir))
    output = @capture_out begin
        cli.run([test_pkg_dir]; verbose=true)
    end
    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
src/TestPackage.jl                                1          0     100.0%
src/methods.jl                                    3          1      66.7%
src/more_methods.jl                               2          2       0.0%
test/runtests.jl                                  0          0        N/A
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cur_dir)  # Restore current directory

    # `paths` is empty and current directory is a Julia package, verbose=false
    cd(test_pkg_dir)
    output = @capture_out begin
        cli.run([])
    end
    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
src/TestPackage.jl                                1          0     100.0%
src/methods.jl                                    3          1      66.7%
src/more_methods.jl                               2          2       0.0%
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cur_dir)  # Restore current directory

    # `paths` is empty and current directory is not a Julia package, verbose=false
    cd(joinpath(test_pkg_dir, "src"))
    output = @capture_out begin
        cli.run([])
    end
    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
TestPackage.jl                                    1          0     100.0%
methods.jl                                        3          1      66.7%
more_methods.jl                                   2          2       0.0%
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cur_dir)  # Restore current directory
end
