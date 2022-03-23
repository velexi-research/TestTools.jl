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
Unit tests for the `EnhancedTestSet` type.

This set of unit tests checks the behavior of `EnhancedTestSet` when the test set type is
`EnhancedTestSet{FallbackTestSet}` (i.e., fail-fast).
"""

# --- Imports

# Standard library
using Test
using Test: DefaultTestSet, FallbackTestSet, FallbackTestSetException

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

@testset "EnhancedTestSet{FallbackTestSet} Tests" begin
    test_set_type = EnhancedTestSet{FallbackTestSet}

    # Single-level test set with a failing test
    error_type = Nothing
    error_message = ""
    output = strip(@capture_out begin
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
    end)

    @test error_type == EnhancedTestSetException
    @test error_message == "FallbackTestSetException occurred"

    expected_prefix = strip("""
                            =====================================================
                            Test Failed at $(@__FILE__):45
                              Expression: 1 == 2
                               Evaluated: 1 == 2
                            """)
    @test startswith(output, expected_prefix)

    # Nested test sets with a failing test
    error_type = Nothing
    error_message = ""
    output = strip(@capture_out begin
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
    end)

    @test error_type == EnhancedTestSetException
    @test error_message == "FallbackTestSetException occurred"

    expected_prefix = strip("""
                            =====================================================
                            Test Failed at $(@__FILE__):73
                              Expression: 1 == 2
                               Evaluated: 1 == 2
                            """)
    @test startswith(output, expected_prefix)

    # --- Nested DefaultTestSet tests
    #
    # * Tests Test.record(EnhancedTestSet{FallbackTestSet}, DefaultTestSet) needed for
    #   backward compatibility with Julia<=1.3.

    default_test_set = DefaultTestSet

    # ------ DefaultTest nested under single EnhancedTestSet{FallbackTestSet} test set

    # With failing tests
    error_type = Nothing
    error_message = ""
    output = (@capture_out begin
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
    end)

    @test error_type == FallbackTestSetException

    expected_prefix = strip("""
                            Failing test: Test Failed at $(@__FILE__):114
                              Expression: 1 == 2
                               Evaluated: 1 == 2
                            """)
    @test startswith(output, expected_prefix)

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

    # ------ DefaultTest nested under multiple EnhancedTestSet{FallbackTestSet} test sets

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

    @test error_type == EnhancedTestSetException
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
