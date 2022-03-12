"""
Unit tests for the methods in `jlcoverage/utils.jl`.

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
using Test: DefaultTestSet

# External packages
using Coverage: Coverage
using Suppressor

# Local modules
using TestTools.jlcoverage
using TestTools.jltest: TestSetPlus

# --- Tests

@testset TestSetPlus "jlcoverage.display_coverage()" begin

    # --- Preparations

    # Get current directory
    cwd = pwd()

    # Generate coverage data for TestPackage
    test_pkg_dir = joinpath(@__DIR__, "data", "TestPackage")
    cmd_options = `--startup-file=no --project=@. -O0`
    cmd = `julia $(cmd_options) -e 'import Pkg; Pkg.test(coverage=true)'`
    @suppress begin
        Base.run(Cmd(cmd; dir=test_pkg_dir); wait=true)
    end

    # Process coverage data
    test_pkg_src_dir = joinpath(test_pkg_dir, "src")
    local coverage
    @suppress begin
        coverage = Coverage.process_folder(test_pkg_src_dir)
    end

    # --- Exercise functionality and check results

    # Case: default keyword arguments
    cd(test_pkg_dir)
    output = @capture_out begin
        display_coverage(coverage)
    end

    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
$(joinpath("src", "TestPackage.jl"))                                1          0     100.0%
$(joinpath("src", "methods.jl"))                                    3          1      66.7%
$(joinpath("src", "more_methods.jl"))                               2          2       0.0%
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cwd)  # Restore current directory

    # Case: startpath = test/jlcoverage/data/TestPackage/src/
    cd(test_pkg_dir)
    startpath = "src"
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
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
    cd(cwd)  # Restore current directory

    # Case: startpath = pwd()/test/jlcoverage/data/TestPackage/src/
    cd(test_pkg_dir)
    startpath = joinpath(pwd(), "src")
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
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
    cd(cwd)  # Restore current directory

    # Case: startpath = ""
    cd(test_pkg_dir)
    startpath = ""
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
    end

    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
$(joinpath(test_pkg_src_dir, "TestPackage.jl"))               1          0     100.0%
$(joinpath(test_pkg_src_dir, "methods.jl"))               3          1      66.7%
$(joinpath(test_pkg_src_dir, "more_methods.jl"))               2          2       0.0%
-------------------------------------------------------------------------------
TOTAL                                             6          3      50.0%
"""
    @test output == expected_output
    cd(cwd)  # Restore current directory

    # --- Clean up

    # Delete coverage data files
    @suppress begin
        Coverage.clean_folder(test_pkg_dir)
    end

    # Remove Manifest.toml
    rm(joinpath(test_pkg_dir, "Manifest.toml"); force=true)
end
