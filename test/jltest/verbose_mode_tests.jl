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
Unit tests to test methods in `jltest/utils.jl`
"""

# --- Imports

# Standard library
using Test
using Test: DefaultTestSet

# External packages
using Suppressor

# Local modules
using TestTools: jltest
using TestTools.jltest: cli

# --- Preparations

# Construct path to test directory
test_dir = joinpath(@__DIR__, "data-basic-tests")
test_dir_relpath = relpath(test_dir)

some_tests_file = joinpath(test_dir, "some_tests.jl")
expected_output_some_tests = "$(joinpath(test_dir_relpath, "some_tests")): .."

# --- Tests

# ------ jltest.run_tests(): tests is a file, test_set_options[:verbose] = true

test_set_options = Dict(:verbose => true)
test_stats = nothing
output = strip(
    @capture_out begin
        global test_stats = jltest.run_tests(
            some_tests_file; test_set_options=test_set_options
        )
    end
)

@test test_stats isa Dict
@test keys(test_stats) == Set([:pass, :fail, :error, :broken])
@test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        test set      |    2      2
          some tests  |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        test set      |    2      2  \\s+\\d+\\.\\d+s
          some tests  |    2      2  \\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)

# ------ jltest.run_tests() with test_set_options[:verbose] = false

test_set_options = Dict(:verbose => false)
test_stats = nothing
output = strip(
    @capture_out begin
        global test_stats = jltest.run_tests(
            some_tests_file; test_set_options=test_set_options
        )
    end
)

@test test_stats isa Dict
@test keys(test_stats) == Set([:pass, :fail, :error, :broken])
@test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        test set      |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        test set      |    2      2  \\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)
@test !occursin("some tests  |", output)

# ------ jltest.run_tests(): tests is a Vector, test_set_options[:verbose] = true

test_set_options = Dict(:verbose => true)
test_stats = nothing
output = strip(
    @capture_out begin
        global test_stats = jltest.run_tests(
            [some_tests_file]; test_set_options=test_set_options
        )
    end
)

@test test_stats isa Dict
@test keys(test_stats) == Set([:pass, :fail, :error, :broken])
@test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        test set      |    2      2
          some tests  |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        test set      |    2      2  \\s+\\d+\\.\\d+s
          some tests  |    2      2  \\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)

# ------ jltest.run_tests(): tests is a Vector, test_set_options[:verbose] = false

test_set_options = Dict(:verbose => false)
test_stats = nothing
output = strip(
    @capture_out begin
        global test_stats = jltest.run_tests(
            [some_tests_file]; test_set_options=test_set_options
        )
    end
)

@test test_stats isa Dict
@test keys(test_stats) == Set([:pass, :fail, :error, :broken])
@test test_stats == Dict(:pass => 2, :fail => 0, :error => 0, :broken => 0)

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        test set      |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        test set      |    2      2  \\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)
@test !occursin("some tests  |", output)

# ------ jltest.cli.run(): verbose = true

tests = [some_tests_file]
tests_passed = false
output = strip(@capture_out begin
    global tests_passed = cli.run(tests; verbose=true)
end)

@test tests_passed

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        All tests     |    2      2
          some tests  |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        All tests     |    2      2\\s+\\d+\\.\\d+s
          some tests  |    2      2\\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)

# ------ jltest.cli.run(): verbose = false

tests = [some_tests_file]
tests_passed = false
output = strip(@capture_out begin
    global tests_passed = cli.run(tests; verbose=false)
end)

@test tests_passed

if VERSION < v"1.8-"
    expected_output = strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total
        All tests     |    2      2
        """)
else
    expected_output = Regex(strip("""
        $(joinpath(test_dir_relpath, "some_tests")): ..

        Test Summary: | Pass  Total  Time
        All tests     |    2      2\\s+\\d+\\.\\d+s
        """))
end

@test occursin(expected_output, output)
@test !occursin("some tests  |", output)
