"""
Unit tests for the methods in `jlcoverage/utils.jl`.

Notes
-----
* For the unit tests in this files, failures and errors are expected.

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

    # --- Process coverage files in `data` directory

    src_dir = joinpath(dirname(@__FILE__), "utils_tests-test_package", "TestPackage", "src")
    local coverage
    @suppress begin
        coverage = Coverage.process_folder(src_dir)
    end

    # --- Capture and check output

    output = @capture_out begin
        display_coverage(coverage)
    end
    expected_output = """
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
TestPackage.jl                                    3          0     100.0%
methods.jl                                        3          1      66.7%
more_methods.jl                                   2          2       0.0%
-------------------------------------------------------------------------------
TOTAL                                             8          3      62.5%
"""
    @test output == expected_output
end

# --- Emit message about expected failures and errors

println()
#@info "For $(basename(@__FILE__)), 4 failures and 0 errors are expected."
