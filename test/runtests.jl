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

# --- Normal unit tests

tests = [
    "jltest/TestSetPlus_passing_tests.jl",
    "jltest/TestSetPlus_fail_fast_tests.jl",
    "jltest/cli_tests.jl",
]
TestTools.jltest.run_tests(tests; name="jltest")

# --- jltest unit tests that have expected failures and errors

local error_type, error_message

# TestSetPlus with failing tests
println()
output = @capture_out begin
    try
        @testset TestSetPlus "TestSetPlus" begin
            TestTools.jltest.run_tests(
                ["jltest/TestSetPlus_failing_tests.jl"]; name="failing tests"
            )
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end

print("jltest/TestSetPlus_failing_tests: ")
@testset TestSetPlus "TestSetPlus: check for expected test failures" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 7 passed, 6 failed, 1 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = """
jltest/TestSetPlus_failing_tests: .......


Test Summary:                            | Pass  Fail  Error  Total
TestSetPlus                              |    7     6      1     14
  failing tests                          |    7     6      1     14
    TestSetPlus: Array equality test     |          1             1
    TestSetPlus: Dict equality test      |          1             1
    TestSetPlus: String equality test    |          1             1
    TestSetPlus: Boolean expression test |          1             1
    TestSetPlus: Exception test          |                 1      1
    TestSetPlus: inequality test         |          1             1
    TestSetPlus: Matrix equality test    |          1             1
"""
    @test strip(output) == strip(expected_output)
end

# utils.jl
println()
output = @capture_out begin
    try
        @testset TestSetPlus "jltest" begin
            TestTools.jltest.run_tests(["jltest/utils_tests.jl"]; name="utils tests")
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end

print("jltest/utils_tests: ")
@testset TestSetPlus "jltest.utils: check for expected test failures" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 36 passed, 4 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = """
jltest/utils_tests: ..................


Test Summary:                 | Pass  Fail  Total
jltest                        |   36     4     40
  utils tests                 |   36     4     40
    jltest.run_tests()        |   31     4     35
                              |    2            2
                              |    2            2
                              |    5     1      6
                              |    5     1      6
                              |    7     1      8
                              |    5     1      6
      test-name               |    1     1      2
                              |    1     1      2
    jltest.autodetect_tests() |    5            5
"""
    @test strip(output) == strip(expected_output)
end

println()
