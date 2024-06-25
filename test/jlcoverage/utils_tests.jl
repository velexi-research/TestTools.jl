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
Unit tests for the methods in `jlcoverage/utils.jl`.
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
using TestTools.jltest: EnhancedTestSet

# --- Helper functions

function make_windows_safe_regex(s::AbstractString)
    if Sys.iswindows()
        s = replace(s, "\\" => "\\\\")
    end

    return s
end

# --- Tests

@testset EnhancedTestSet "jlcoverage.display_coverage()" begin

    # --- Preparations

    # Get current directory
    cwd = pwd()

    # Set up temporary directory for testing
    tmp_dir = mktempdir()
    test_pkg_dir = joinpath(tmp_dir, "TestPackage")
    cp(joinpath(@__DIR__, "data", "TestPackage"), test_pkg_dir)

    # Generate coverage data for TestPackage
    cmd_options = `--startup-file=no --project=@. -O0`
    cmd = Cmd(
        `julia $(cmd_options) -e 'import Pkg; Pkg.test(coverage=true)'`; dir=test_pkg_dir
    )
    @suppress begin
        Base.run(cmd; wait=true)
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

    # Case: startpath = test/jlcoverage/data/TestPackage/src/
    cd(test_pkg_dir)
    startpath = "src"
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
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

    # Case: startpath = pwd()/test/jlcoverage/data/TestPackage/src/
    cd(test_pkg_dir)
    startpath = joinpath(pwd(), "src")
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
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

    # Case: startpath = ""
    cd(test_pkg_dir)
    startpath = ""
    output = @capture_out begin
        display_coverage(coverage; startpath=startpath)
    end

    expected_output = Regex(strip("""
--------------------------------------------------------------------------------
File                                          Lines of Code    Missed  Coverage
--------------------------------------------------------------------------------
$(joinpath(test_pkg_src_dir, "TestPackage.jl"))\\s+1\\s+0    100.0%
$(joinpath(test_pkg_src_dir, "methods.jl"))\\s+3\\s+1     66.7%
$(joinpath(test_pkg_src_dir, "more_methods.jl"))\\s+2\\s+2      0.0%
--------------------------------------------------------------------------------
TOTAL                                                     6         3     50.0%
"""))
    println(expected_output)
    println(output)
    @test occursin(expected_output, output)

    cd(cwd)  # Restore current directory
end
