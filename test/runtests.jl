#   Copyright (c) 2022 Velexi Corporation
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
Unit test runner for the TestTools.jl package.
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

local log_message
local error_type, error_message

# TestSetPlus with failing tests
println()
test_file = joinpath("jltest", "TestSetPlus_failing_tests.jl")
output = strip(
    @capture_out begin
        try
            @testset TestSetPlus "TestSetPlus" begin
                global log_message = strip(
                    @capture_err begin
                        jltest.run_tests(test_file; name="failing tests")
                    end
                )
            end
        catch error
            bt = catch_backtrace()
            global error_type = typeof(error)
            global error_message = sprint(showerror, error, bt)
        end
    end
)

print("jltest/TestSetPlus_failing_tests: ")
@testset TestSetPlus "TestSetPlus: check for expected test failures" begin
    @test log_message ==
        "[ Info: For TestSetPlus_failing_tests.jl, 6 failures and 1 error are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 7 passed, 6 failed, 1 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip(
        """
        $(joinpath("jltest", "TestSetPlus_failing_tests")): .......


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
    )
    @test output == expected_output
end

# TestSetPlus with nested test sets
println()
test_file = joinpath("jltest", "TestSetPlus_nested_test_set_tests.jl")
output = strip(
    @capture_out begin
        try
            @testset TestSetPlus "TestSetPlus" begin
                global log_message = strip(
                    @capture_err begin
                        jltest.run_tests(test_file; name="nested test set tests")
                    end
                )
            end
        catch error
            bt = catch_backtrace()
            global error_type = typeof(error)
            global error_message = sprint(showerror, error, bt)
        end
    end
)

print("jltest/TestSetPlus_nested_test_set_tests: ")
@testset TestSetPlus "TestSetPlus: check for expected test failures" begin
    @test log_message ==
        "[ Info: For TestSetPlus_nested_test_set_tests.jl, 2 failures and 0 error are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 2 passed, 2 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip(
        """
        $(joinpath("jltest", "TestSetPlus_nested_test_set_tests")): ..


        Test Summary:                                 | Pass  Fail  Total
        TestSetPlus                                   |    2     2      4
          nested test set tests                       |    2     2      4
            TestSetPlus: nested inherited TestSetPlus |          1      1
              Nested Inherited Test Set               |          1      1
            TestSetPlus: nested DefaultTestSet        |          1      1
              DefaultTestSet Nested in TestSetPlus    |          1      1
        """
    )
    @test output == expected_output
end

# utils.jl
println()
test_file = joinpath("jltest", "utils_tests.jl")
output = strip(
    @capture_out begin
        try
            @testset TestSetPlus "jltest" begin
                global log_message = strip(
                    @capture_err begin
                        jltest.run_tests(test_file; name="utils tests")
                    end
                )
            end
        catch error
            bt = catch_backtrace()
            global error_type = typeof(error)
            global error_message = sprint(showerror, error, bt)
        end
    end
)

print("jltest/utils_tests: ")
@testset TestSetPlus "jltest.utils: check for expected test failures" begin
    @test log_message == "[ Info: For utils_tests.jl, 6 failures and 0 errors are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 54 passed, 6 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip(
        """
        $(joinpath("jltest", "utils_tests")): ..............................


        Test Summary:                                    | Pass  Fail  Total
        jltest                                           |   54     6     60
          utils tests                                    |   54     6     60
            jltest.run_tests(): basic tests              |   38     6     44
                                                         |    2            2
                                                         |    2            2
                                                         |    6     2      8
                                                         |    6     2      8
                  failing tests                          |    1     1      2
                  some tests                             |    2            2
                                                         |    8     2     10
                some tests                               |    2            2
                                                         |    6     2      8
                  failing tests                          |    1     1      2
                  some tests                             |    2            2
                                                         |    2            2
              test-name                                  |    1     1      2
                                                         |    1     1      2
                failing tests                            |    1     1      2
            jltest.run_tests(): log message tests        |    9            9
            jltest.run_tests(): current directory checks |    4            4
            jltest.find_tests()                          |    3            3
            """
    )

    @test output == expected_output
end

# cli.jl
println()
test_file = joinpath("jltest", "cli_tests.jl")
output = strip(
    @capture_out begin
        try
            @testset TestSetPlus "jltest" begin
                global log_message = strip(
                    @capture_err begin
                        jltest.run_tests(test_file; name="cli tests")
                    end
                )
            end
        catch error
            bt = catch_backtrace()
            global error_type = typeof(error)
            global error_message = sprint(showerror, error, bt)
        end
    end
)

print("jltest/cli_tests: ")
@testset TestSetPlus "jltest.cli: check for expected test failures" begin
    @test log_message == "[ Info: For cli_tests.jl, 4 failures and 0 errors are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 45 passed, 4 failed, 0 errored, 0 broken."

    # Check output from TestSetPlus
    expected_output = strip(
        """
        $(joinpath("jltest", "cli_tests")): .............................


        Test Summary:                     | Pass  Fail  Total
        jltest                            |   45     4     49
          cli tests                       |   45     4     49
            jltest.cli.parse_args()       |    8            8
            jltest.cli.run(): basic tests |   36     4     40
              All tests                   |    4            4
              All tests                   |    3     1      4
                failing tests             |    1     1      2
              All tests                   |    3     1      4
                failing tests             |    1     1      2
              All tests                   |    6     2      8
                failing tests             |    1     1      2
                some tests                |    2            2
            jltest.cli.run(): error cases |    1            1
        """
    )
    @test output == expected_output
end
