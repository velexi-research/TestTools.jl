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

# Standard library
using Test

# External packages
using Suppressor

# Local package
using TestTools.jltest

# --- Preparations

# Change to test directory
cd(dirname(@__FILE__))

# --- Normal unit tests

tests = [
    joinpath("jltest", "TestSetPlus_passing_tests.jl"),
    joinpath("jltest", "TestSetPlus_fail_fast_tests.jl"),
    joinpath("jltest", "cli_tests.jl"),
]
jltest.run_tests(tests; name="jltest")

# --- jltest unit tests that have expected failures and errors

local error_type, error_message

# TestSetPlus with failing tests
println()
test_file = joinpath("jltest", "TestSetPlus_failing_tests.jl")
output = @capture_out begin
    try
        @testset TestSetPlus "TestSetPlus" begin
            jltest.run_tests(test_file; name="failing tests")
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
test_file = joinpath("jltest", "utils_tests.jl")
output = @capture_out begin
    try
        @testset TestSetPlus "jltest" begin
            jltest.run_tests(test_file; name="utils tests")
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
        "Some tests did not pass: 35 passed, 4 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = """
jltest/utils_tests: .................


Test Summary:                 | Pass  Fail  Total
jltest                        |   35     4     39
  utils tests                 |   35     4     39
    jltest.run_tests()        |   32     4     36
                              |    2            2
                              |    2            2
                              |    5     1      6
                              |    5     1      6
                              |    7     1      8
                              |    5     1      6
      test-name               |    1     1      2
                              |    1     1      2
    jltest.autodetect_tests() |    3            3
"""
    @test strip(output) == strip(expected_output)
end

println()
