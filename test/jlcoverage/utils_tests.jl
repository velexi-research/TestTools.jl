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
using Coverage
using Suppressor

# Local modules
using TestTools.jlcoverage
using TestTools.jltest: TestSetPlus

# --- Tests

@testset TestSetPlus "jlcoverage.display_coverage()" begin

    # --- Preparations

    # Generate coverage data for TestPackage
    test_pkg_dir = joinpath(dirname(@__FILE__), "utils_tests-test_package", "TestPackage")
    cmd = `julia --startup-file=no --project=@. -e 'import Pkg; Pkg.test(coverage=true)'`
    @suppress begin
        Base.run(Cmd(cmd; dir=test_pkg_dir); wait=true)
    end

    # Process coverage data
    test_pkg_src_dir = joinpath(test_pkg_dir, "src")
    local coverage
    @suppress begin
        coverage = Coverage.process_folder(test_pkg_src_dir)
    end

    # --- Capture and check output

    output = @capture_out begin
        display_coverage(coverage)
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
end
