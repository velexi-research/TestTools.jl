"""
Unit test runner for the TestTools.jl package.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

# External packages
using Suppressor

# Local package
using TestTools

# --- Run tests

# ------ Normal unit tests

tests = ["jltest/TestSetPlus_passing_tests.jl"]
TestTools.jltest.run(tests; name="jltest", verbose=true)

# ------ jltest unit tests that test the behavior of failing tests

local error_type, error_message
output = @capture_out begin
    try
        @testset TestSetPlus "TestSetPlus" begin
            TestTools.jltest.run(
                ["jltest/TestSetPlus_failing_tests.jl"]; name="failing tests"
            )
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end

println()
print("jltest/TestSetPlus_failing_tests: ")
@testset TestSetPlus "TestSetPlus: check failed tests" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 3 passed, 3 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = """
jltest/TestSetPlus_failing_tests: ...

Test Summary:                     | Pass  Fail  Total
TestSetPlus                       |    3     3      6
  failing tests                   |    3     3      6
    TestSetPlus: Array diff test  |          1      1
    TestSetPlus: Dict diff test   |          1      1
    TestSetPlus: String diff test |          1      1
"""
    @test strip(output) == strip(expected_output)
end

println()
