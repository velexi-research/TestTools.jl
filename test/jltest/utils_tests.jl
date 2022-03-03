"""
Unit tests for the methods in `jltest/utils.jl`. 

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

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "TestSetPlus: run_tests" begin
    @test 1 == 2 broken = true
end

@testset TestSetPlus "TestSetPlus: autodetect_tests" begin
    # normal operation
    dir = dirname(@__FILE__)
    tests = autodetect_tests(dir)
    expected_tests = [
        "TestSetPlus_fail_fast_tests.jl",
        "TestSetPlus_passing_tests.jl",
        "TestSetPlus_failing_tests.jl",
        "utils_tests.jl",
    ]
    for test_file in expected_tests
        @test joinpath(dir, test_file) in tests
    end

    # directory containing "runtests.jl"
    dir = dirname(dirname(@__FILE__))
    tests = autodetect_tests(dir)
    @test tests == []
end
