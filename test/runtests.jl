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
Unit test runner for the TestTools package.
"""

# --- Imports

# Standard library
using Pkg: Pkg
using Test

# External packages
using Aqua
using Suppressor

# Local package
using TestTools
using TestTools.jltest

#cmd = Cmd(`\$HOME/.juliaup/bin/julia --project=. -e "import Pkg"`)
cmd = Cmd(`pwd`)
console = @capture_out begin
    Base.run(cmd)
end
println(console)
cmd = Cmd(`ls`)
console = @capture_out begin
    Base.run(cmd)
end
println(console)

# --- Helper functions

function make_windows_safe_regex(s::AbstractString)
    if Sys.iswindows()
        s = replace(s, "\\" => "\\\\")
    end

    return s
end

# --- Preparations

# Change to test directory
#
# Note: this is needed for consistency of results when tests are run via
# `jltest runtests.jl` and `import Pkg; Pkg.test()`
cd(@__DIR__)

# Save current working directory so that it can be restored before running each set of
# tests.
cwd = pwd()

# --- Normal unit tests

# installer tests
println()
println("=============================== pkg tests start ===============================")

cd(cwd)
tests = [joinpath(@__DIR__, "pkg_tests.jl")]
jltest.run_tests(tests; desc="installer")

println()
println("================================ pkg tests end ================================")
println()

# `jltest` tests
println("============================== jltest tests start =============================")

cd(cwd)
tests = [
    joinpath(@__DIR__, "jltest", "isolated_test_module_tests.jl"),
    joinpath(@__DIR__, "jltest", "EnhancedTestSet_utils_tests.jl"),
    joinpath(@__DIR__, "jltest", "EnhancedTestSet_passing_tests.jl"),
    joinpath(@__DIR__, "jltest", "EnhancedTestSet_fail_fast_tests.jl"),
]
jltest.run_tests(tests; desc="jltest")

# `jltest` verbose mode tests
cd(cwd)
tests = [joinpath(@__DIR__, "jltest", "verbose_mode_tests.jl")]
jltest.run_tests(tests; desc="jltest: verbose mode tests", test_set_type=nothing)

println()
println()
println("=============================== jltest tests end ==============================")
println()

# `jlcodestyle` tests
println("=========================== jlcodestyle tests start ===========================")

cd(cwd)
tests = [joinpath(@__DIR__, "jlcodestyle", "cli_tests.jl")]
jltest.run_tests(tests; desc="jlcodestyle")

println()
println("============================ jlcodestyle tests end ============================")
println()

# `jlcoverage` tests
println("============================ jlcoverage tests start ===========================")

cd(cwd)
tests = [
    joinpath(@__DIR__, "jlcoverage", "cli_tests.jl"),
    joinpath(@__DIR__, "jlcoverage", "utils_tests.jl"),
]
jltest.run_tests(tests; desc="jlcoverage")

println()
println("============================= jlcoverage tests end ============================")
println()

# --- jltest unit tests that have expected failures and errors

println("========================= EnhancedTestSet tests start =========================")

# EnhancedTestSet with failing tests
println()
test_file = joinpath(@__DIR__, "jltest", "EnhancedTestSet_failing_tests.jl")

local log_message
local error_type, error_message
output = strip(
    @capture_out begin
        try
            @testset EnhancedTestSet "EnhancedTestSet" begin
                global log_message = strip(
                    @capture_err begin
                        cd(cwd)
                        jltest.run_tests(test_file; desc="failing tests")
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

print("jltest/EnhancedTestSet_failing_tests: ")

@testset EnhancedTestSet "EnhancedTestSet: check for expected test failures" begin
    @test log_message ==
        "[ Info: For EnhancedTestSet_failing_tests.jl, 6 failures and 1 error are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 7 passed, 6 failed, 1 errored, 0 broken."

    # Check output from EnhancedTestSet
    if VERSION < v"1.8-"
        expected_output = strip(
            """
            $(joinpath("jltest", "EnhancedTestSet_failing_tests")): .......


            Test Summary:                                | Pass  Fail  Error  Total
            EnhancedTestSet                              |    7     6      1     14
              failing tests                              |    7     6      1     14
                EnhancedTestSet: Array equality test     |          1             1
                EnhancedTestSet: Dict equality test      |          1             1
                EnhancedTestSet: String equality test    |          1             1
                EnhancedTestSet: Boolean expression test |          1             1
                EnhancedTestSet: Exception test          |                 1      1
                EnhancedTestSet: inequality test         |          1             1
                EnhancedTestSet: Matrix equality test    |          1             1
            """
        )

        @test output == expected_output
    else
        test_path = make_windows_safe_regex(
            joinpath("jltest", "EnhancedTestSet_failing_tests")
        )
        expected_output = Regex(
            strip(
                """
                $(test_path): .......


                Test Summary:                                \\| Pass  Fail  Error  Total\\s+Time
                EnhancedTestSet                              \\|    7     6      1     14\\s+\\d+\\.\\d+s
                  failing tests                              \\|    7     6      1     14\\s+\\d+\\.\\d+s
                    EnhancedTestSet: Array equality test     \\|          1             1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: Dict equality test      \\|          1             1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: String equality test    \\|          1             1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: Boolean expression test \\|          1             1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: Exception test          \\|                 1      1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: inequality test         \\|          1             1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: Matrix equality test    \\|          1             1\\s+\\d+\\.\\d+s
                """,
            ),
        )

        @test occursin(expected_output, output)
    end
end

# EnhancedTestSet with nested test sets
println()
test_file = joinpath(@__DIR__, "jltest", "EnhancedTestSet_nested_test_set_tests.jl")

local log_message
local error_type, error_message
output = strip(
    @capture_out begin
        try
            @testset EnhancedTestSet "EnhancedTestSet" begin
                global log_message = strip(
                    @capture_err begin
                        cd(cwd)
                        jltest.run_tests(test_file; desc="nested test set tests")
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

print("jltest/EnhancedTestSet_nested_test_set_tests: ")
@testset EnhancedTestSet "EnhancedTestSet: check for expected test failures" begin
    @test log_message ==
        "[ Info: For EnhancedTestSet_nested_test_set_tests.jl, 2 failures and 0 error are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 2 passed, 2 failed, 0 errored, 0 broken."

    # Check output from EnhancedTestSet
    if VERSION < v"1.8-"
        expected_output = strip(
            """
            $(joinpath("jltest", "EnhancedTestSet_nested_test_set_tests")): ..


            Test Summary:                                         | Pass  Fail  Total
            EnhancedTestSet                                       |    2     2      4
              nested test set tests                               |    2     2      4
                EnhancedTestSet: nested inherited EnhancedTestSet |          1      1
                  Nested Inherited Test Set                       |          1      1
                EnhancedTestSet: nested DefaultTestSet            |          1      1
                  DefaultTestSet Nested in EnhancedTestSet        |          1      1
            """
        )

        @test output == expected_output
    else
        test_path = make_windows_safe_regex(
            joinpath("jltest", "EnhancedTestSet_nested_test_set_tests")
        )
        expected_output = Regex(
            strip(
                """
                $(test_path): ..


                Test Summary:                                         \\| Pass  Fail  Total\\s+Time
                EnhancedTestSet                                       \\|    2     2      4\\s+\\d+\\.\\d+s
                  nested test set tests                               \\|    2     2      4\\s+\\d+\\.\\d+s
                    EnhancedTestSet: nested inherited EnhancedTestSet \\|          1      1\\s+\\d+\\.\\d+s
                      Nested Inherited Test Set                       \\|          1      1\\s+\\d+\\.\\d+s
                    EnhancedTestSet: nested DefaultTestSet            \\|          1      1\\s+\\d+\\.\\d+s
                      DefaultTestSet Nested in EnhancedTestSet        \\|          1      1\\s+\\d+\\.\\d+s
                """,
            ),
        )

        @test occursin(expected_output, output)
    end
end

println()
println("========================== EnhancedTestSet tests end ==========================")
println()

# utils.jl
println("=========================== jltest.utils tests start ==========================")
println()

test_file = joinpath(@__DIR__, "jltest", "utils_tests.jl")

local log_message
local error_type, error_message
output = strip(
    @capture_out begin
        try
            @testset EnhancedTestSet "jltest" begin
                global log_message = strip(
                    @capture_err begin
                        cd(cwd)
                        jltest.run_tests(test_file; desc="utils tests")
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
@testset EnhancedTestSet "jltest.utils: check for expected test failures" begin
    @test error_type == TestSetException

    @test log_message ==
        "[ Info: For utils_tests.jl, 13 failures and 0 errors are expected."

    @test error_message ==
        "Some tests did not pass: 141 passed, 13 failed, 0 errored, 0 broken."

    # Check output from EnhancedTestSet
    if VERSION < v"1.8-"
        expected_output = strip(
            """
            $(joinpath("jltest", "utils_tests")): .......................................................................................


            Test Summary:                                    | Pass  Fail  Total
            jltest                                           |  141    13    154
              utils tests                                    |  141    13    154
                jltest.run_tests(): basic tests              |   97    11    108
                  test set                                   |    2            2
                  test set                                   |    2            2
                  test set                                   |    8     2     10
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                    more tests                               |    2            2
                  test set                                   |   10     2     12
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                    more tests                               |    2            2
                    some tests                               |    2            2
                  test set                                   |    2            2
                  test description                           |    1     1      2
                  test set                                   |    1     1      2
                    failing tests                            |    1     1      2
                  failing tests                              |    1     1      2
                  test set                                   |    6     2      8
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                  test set                                   |    8     2     10
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                    more tests                               |    2            2
                jltest.run_tests(): log message tests        |    9            9
                jltest.run_tests(): current directory checks |    4            4
                jltest.run_tests(): JLTEST_FAIL_FAST tests   |   17     2     19
                  test set                                   |    3     1      4
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                  test set                                   |    3     1      4
                    failing tests                            |    1     1      2
                    some tests                               |    2            2
                jltest.find_tests()                          |    4            4
                jltest: Pkg.test() tests                     |    2            2
                jltest.get_test_statistics()                 |    8            8
            """,
        )

        @test output == expected_output
    else
        test_path = make_windows_safe_regex(joinpath("jltest", "utils_tests"))
        expected_output = Regex(
            strip(
                """
                $(test_path): ........................................................................................


                Test Summary:                                    \\| Pass  Fail  Total\\s+Time
                jltest                                           \\|  141    13    154\\s+\\d+\\.\\d+s
                  utils tests                                    \\|  141    13    154\\s+\\d+\\.\\d+s
                    jltest\\.run_tests\\(\\): basic tests              \\|   97    11    108\\s+\\d+\\.\\d+s
                      test set                                   \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|    8     2     10\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                        more tests                               \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|   10     2     12\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                        more tests                               \\|    2            2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|    2            2\\s+\\d+\\.\\d+s
                      test description                           \\|    1     1      2\\s+\\d+\\.\\d+s
                      test set                                   \\|    1     1      2\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                      failing tests                              \\|    1     1      2\\s+\\d+\\.\\d+s
                      test set                                   \\|    6     2      8\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|    8     2     10\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                        more tests                               \\|    2            2\\s+\\d+\\.\\d+s
                    jltest\\.run_tests\\(\\): log message tests        \\|    9            9\\s+\\d+\\.\\d+s
                    jltest\\.run_tests\\(\\): current directory checks \\|    4            4\\s+\\d+\\.\\d+s
                    jltest\\.run_tests\\(\\): JLTEST_FAIL_FAST tests   \\|   17     2     19\\s+\\d+\\.\\d+s
                      test set                                   \\|    3     1      4\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                      test set                                   \\|    3     1      4\\s+\\d+\\.\\d+s
                        failing tests                            \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                               \\|    2            2\\s+\\d+\\.\\d+s
                    jltest\\.find_tests\\(\\)                          \\|    4            4\\s+\\d+\\.\\d+s
                    jltest: Pkg\\.test\\(\\) tests                     \\|    2            2\\s+\\d+\\.\\d+s
                    jltest\\.get_test_statistics\\(\\)                 \\|    8            8\\s+\\d+\\.\\d+s
                """,
            ),
        )

        @test occursin(expected_output, output)
    end
end

println()
println("============================ jltest.utils tests end ===========================")
println()

# cli.jl
println("============================ jltest.cli tests start ===========================")
println()

test_file = joinpath(@__DIR__, "jltest", "cli_tests.jl")

local log_message
local error_type, error_message
output = strip(
    @capture_out begin
        try
            @testset EnhancedTestSet "jltest" begin
                global log_message = strip(
                    @capture_err begin
                        cd(cwd)
                        jltest.run_tests(test_file; desc="cli tests")
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
@testset EnhancedTestSet "jltest.cli: check for expected test failures" begin
    @test log_message == "[ Info: For cli_tests.jl, 5 failures and 0 errors are expected."

    @test error_type == TestSetException
    @test error_message ==
        "Some tests did not pass: 66 passed, 5 failed, 0 errored, 0 broken."

    # Check output from EnhancedTestSet
    if VERSION < v"1.8-"
        expected_output = strip(
            """
            $(joinpath("jltest", "cli_tests")): .............................................


            Test Summary:                                | Pass  Fail  Total
            jltest                                       |   66     5     71
              cli tests                                  |   66     5     71
                jltest.cli.parse_args()                  |   12           12
                jltest.cli.run(): basic tests            |   22     2     24
                  All tests                              |    4            4
                  All tests                              |    8     2     10
                    failing tests                        |    1     1      2
                    some tests                           |    2            2
                    more tests                           |    2            2
                jltest.cli.run(): keyword argument tests |   31     3     34
                  failing tests                          |    1     1      2
                  All tests                              |    6     2      8
                    failing tests                        |    1     1      2
                    some tests                           |    2            2
                jltest.cli.run(): error cases            |    1            1
            """,
        )

        @test output == expected_output
    else
        test_path = make_windows_safe_regex(joinpath("jltest", "cli_tests"))
        expected_output = Regex(
            strip(
                """
                $(test_path): .............................................


                Test Summary:                                \\| Pass  Fail  Total\\s+Time
                jltest                                       \\|   66     5     71\\s+\\d+\\.\\d+s
                  cli tests                                  \\|   66     5     71\\s+\\d+\\.\\d+s
                    jltest\\.cli\\.parse_args\\(\\)                  \\|   12           12\\s+\\d+\\.\\d+s
                    jltest\\.cli\\.run\\(\\): basic tests            \\|   22     2     24\\s+\\d+\\.\\d+s
                      All tests                              \\|    4            4\\s+\\d+\\.\\d+s
                      All tests                              \\|    8     2     10\\s+\\d+\\.\\d+s
                        failing tests                        \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                           \\|    2            2\\s+\\d+\\.\\d+s
                        more tests                           \\|    2            2\\s+\\d+\\.\\d+s
                    jltest\\.cli\\.run\\(\\): keyword argument tests \\|   31     3     34\\s+\\d+\\.\\d+s
                      failing tests                          \\|    1     1      2\\s+\\d+\\.\\d+s
                      All tests                              \\|    6     2      8\\s+\\d+\\.\\d+s
                        failing tests                        \\|    1     1      2\\s+\\d+\\.\\d+s
                        some tests                           \\|    2            2\\s+\\d+\\.\\d+s
                    jltest\\.cli\\.run\\(\\): error cases            \\|    1            1\\s+\\d+\\.\\d+s
                """,
            ),
        )

        @test occursin(expected_output, output)
    end
end

println()
println("============================= jltest.cli tests end ============================")
println()

# --- Aqua.jl tests

println("============================= Aqua.jl checks start ============================")
println()

print("Aqua.jl: ")

cd(cwd)

# Refresh Julia environment
#Pkg.activate(cwd)
#Pkg.instantiate()

@testset EnhancedTestSet "Aqua.jl code quality checks" begin
    Aqua.test_all(
        TestTools;
        stale_deps=(ignore=[:Aqua],),
        deps_compat=(ignore=[:Distributed, :Logging, :Printf, :Test],),
    )
end

println()
println("============================== Aqua.jl checks end =============================")
println()
