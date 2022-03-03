"""
Unit tests for the `TestSetPlus` type.

This set of unit tests checks the behavior of `TestSetPlus` when the test set type is
`TestSetPlus{FallbackTestSet}` (i.e., fail fast).

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
using Test: DefaultTestSet, FallbackTestSet, FallbackTestSetException

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Private helper functions

function check_expected_prefix(output::AbstractString, prefix::String)
    return startswith(lstrip(output), prefix)
end

# --- Tests

@testset "TestSetPlus{FallbackTestSet} Tests" begin
    test_set_type = TestSetPlus{FallbackTestSet}

    # Single-level test set with a failing test
    error_type = Nothing
    error_message = ""
    output = @capture_out begin
        try
            @testset test_set_type "top-level tests" begin
                @test 1 == 2
                @test 1 == 1
            end
        catch error
            error_type = typeof(error)
            error_message = error.msg
            println(error)
        end
    end

    @test error_type == TestSetPlusException
    @test error_message == "FallbackTestSetException occurred"

    prefix = join(
        [
            "=====================================================",
            "Test Failed at $(@__FILE__):43",
            "  Expression: 1 == 2",
            "   Evaluated: 1 == 2",
        ],
        '\n',
    )
    @test check_expected_prefix(output, prefix)

    # Nested test sets with a failing test
    error_type = Nothing
    error_message = ""
    output = @capture_out begin
        try
            @testset test_set_type "top-level tests" begin
                @testset "Test set with failing test" begin
                    @test 1 == 2
                    @test 1 == 1
                end
                @testset "Test set with no failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        catch error
            error_type = typeof(error)
            error_message = error.msg
        end
    end

    @test error_type == TestSetPlusException
    @test error_message == "FallbackTestSetException occurred"

    prefix = join(
        [
            "=====================================================",
            "Test Failed at $(@__FILE__):74",
            "  Expression: 1 == 2",
            "   Evaluated: 1 == 2",
        ],
        '\n',
    )
    @test check_expected_prefix(output, prefix)

    # --- Nested DefaultTestSet tests
    #
    # * Tests Test.record(TestSetPlus{FallbackTestSet}, DefaultTestSet) needed for
    #   backward compatibility with Julia<=1.3.

    default_test_set = DefaultTestSet

    # ------ DefaultTest nested under single TestSetPlus{FallbackTestSet} test set

    # With failing tests
    error_type = Nothing
    error_message = ""
    output = @capture_out begin
        try
            @testset test_set_type "top-level tests" begin
                @testset default_test_set "Failing test" begin
                    @test 1 == 2
                    @test 1 == 1
                end
                @testset default_test_set "No failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        catch error
            error_type = typeof(error)
            error_message = error.msg
        end
    end

    @test error_type == FallbackTestSetException

    prefix = join(
        [
            "Failing test: Test Failed at $(@__FILE__):118",
            "  Expression: 1 == 2",
            "   Evaluated: 1 == 2",
        ],
        '\n',
    )
    @test check_expected_prefix(output, prefix)

    # With no failing tests
    error = nothing
    try
        @testset test_set_type "top-level tests" begin
            @testset default_test_set "No failing tests" begin
                @test 2 == 2
                @test 3 == 3
            end
        end
    catch error
    end

    @test isnothing(error)

    # ------ DefaultTest nested under multiple TestSetPlus{FallbackTestSet} test sets

    # With failing tests
    error_type = Nothing
    error_message = ""
    output = @capture_out begin
        try
            @testset test_set_type "top-level tests" begin
                @testset test_set_type "2nd-level tests" begin
                    @testset default_test_set "Failing test" begin
                        @test 1 == 2
                        @test 1 == 1
                    end
                    @testset default_test_set "No failing tests" begin
                        @test 2 == 2
                        @test 3 == 3
                    end
                end
            end
        catch error
            error_type = typeof(error)
            error_message = error.msg
        end
    end

    @test error_type == TestSetPlusException
    @test error_message == "FallbackTestSetException occurred"

    # With no failing tests
    error = nothing
    try
        @testset test_set_type "top-level tests" begin
            @testset test_set_type "2nd-level tests" begin
                @testset default_test_set "No failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        end
    catch error
    end

    @test isnothing(error)
end
