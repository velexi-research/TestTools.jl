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
cd(@__DIR__)

# --- Normal unit tests

tests = [
    "pkg_tests.jl",
    joinpath("jltest", "TestSetPlus_passing_tests.jl"),
    joinpath("jltest", "TestSetPlus_fail_fast_tests.jl"),
    joinpath("jlcodestyle", "cli_tests.jl"),
    joinpath("jlcoverage", "cli_tests.jl"),
    joinpath("jlcoverage", "utils_tests.jl"),
]
jltest.run_tests(tests; name="jltest")

# --- jltest unit tests that have expected failures and errors

local error_type, error_message

# TestSetPlus with failing tests
println()
test_file = joinpath("jltest", "TestSetPlus_failing_tests.jl")
output = strip(@capture_out begin
    try
        @testset TestSetPlus "TestSetPlus" begin
            jltest.run_tests(test_file; name="failing tests")
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end)

print("jltest/TestSetPlus_failing_tests: ")
@testset TestSetPlus "TestSetPlus: check for expected test failures" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 7 passed, 6 failed, 1 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip("""
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
    """)
    @test output == expected_output
end

# utils.jl
println()
test_file = joinpath("jltest", "utils_tests.jl")
output = strip(@capture_out begin
    try
        @testset TestSetPlus "jltest" begin
            jltest.run_tests(test_file; name="utils tests")
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end)

print("jltest/utils_tests: ")
@testset TestSetPlus "jltest.utils: check for expected test failures" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 35 passed, 4 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip("""
                            jltest/utils_tests: .................


                            Test Summary:                             | Pass  Fail  Total
                            jltest                                    |   35     4     39
                              utils tests                             |   35     4     39
                                jltest.run_tests()                    |   30     4     34
                                                                      |    2            2
                                                                      |    2            2
                                                                      |    5     1      6
                                                                      |    5     1      6
                                                                      |    7     1      8
                                                                      |    5     1      6
                                  test-name                           |    1     1      2
                                                                      |    1     1      2
                                jltest.autodetect_tests()             |    3            3
                                jltest.run_tests(): invalid arguments |    2            2

                                """)
    @test output == expected_output
end

# cli.jl
println()
test_file = joinpath("jltest", "cli_tests.jl")
output = strip(@capture_out begin
    try
        @testset TestSetPlus "jltest" begin
            jltest.run_tests(test_file; name="cli tests")
        end
    catch error
        bt = catch_backtrace()
        global error_type = typeof(error)
        global error_message = sprint(showerror, error, bt)
    end
end)

print("jltest/cli_tests: ")
@testset TestSetPlus "jltest.cli: check for expected test failures" begin
    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 44 passed, 3 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip("""
                            jltest/cli_tests: .............................


                            Test Summary:                     | Pass  Fail  Total
                            jltest                            |   44     3     47
                              cli tests                       |   44     3     47
                                jltest.cli.parse_args()       |    8            8
                                jltest.cli.run()              |   35     3     38
                                  All tests                   |    4            4
                                  All tests                   |    3     1      4
                                  All tests                   |    3     1      4
                                  All tests                   |    5     1      6
                                jltest.cli.run(): error cases |    1            1
                            """)
    @test output == expected_output
end
