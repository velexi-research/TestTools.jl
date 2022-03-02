"""
Unit tests for the `jltest` module.

This set of unit tests checks the behavior of `jltest` for failing tests.
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

# Local modules
using TestTools.jltest

# --- Tests

# Array diff test
output = @capture_out begin
    TestTools.jltest.run_tests([
        joinpath(
            dirname(@__FILE__),
            "TestSetPlus_failing_tests",
            "TestSetPlus_Array_diff_test.jl",
        ),
    ])
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Array diff test: Test Failed",
        "  Expression: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]",
        "",
        "  Diff:",
        "[3, 5, 6, 1, (-)6, (+)9, 8]",
    ],
    "\n",
)

@test startswith(split(lstrip(output), '\n'; limit=2)[2], prefix)

# Dict diff test
output = @capture_out begin
    TestTools.jltest.run_tests([
        joinpath(
            dirname(@__FILE__), "TestSetPlus_failing_tests", "TestSetPlus_Dict_diff_test.jl"
        ),
    ])
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Dict diff test: Test Failed",
        "  Expression: Dict(:foo => \"bar\", :baz => [1, 4, 5], :biz => nothing) " *
        "== Dict(:baz => [1, 7, 5], :biz => 42)",
        "",
        "  Diff:",
        "[Dict{Symbol, Any}, (-):biz => nothing, (-):baz => [1, 4, 5], " *
        "(-):foo => \"bar\", (+):biz => 42, (+):baz => [1, 7, 5]]",
    ],
    "\n",
)

@test startswith(split(lstrip(output), '\n'; limit=2)[2], prefix)

# String diff test
output = @capture_out begin
    TestTools.jltest.run_tests([
        joinpath(
            dirname(@__FILE__),
            "TestSetPlus_failing_tests",
            "TestSetPlus_String_diff_test.jl",
        ),
    ])
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: String diff test: Test Failed",
        "  Expression: \"Lorem ipsum dolor sit amet,\\nconsectetur adipiscing elit, " *
        "sed do\\neiusmod tempor incididunt ut\\nlabore et dolore magna aliqua.\\nUt " *
        "enim ad minim veniam, quis nostrud\\nexercitation ullamco aboris.\" " *
        "== \"Lorem ipsum dolor sit amet,\\nconsectetur adipiscing elit, sed do\\n" *
        "eiusmod temper incididunt ut\\nlabore et dolore magna aliqua.\\nUt enim ad " *
        "minim veniam, quis nostrud\\nexercitation ullamco aboris.\"",
        "",
        "  Diff:",
        "\"\"\"",
        "  Lorem ipsum dolor sit amet,",
        "  consectetur adipiscing elit, sed do",
        "- eiusmod tempor incididunt ut",
        "+ eiusmod temper incididunt ut",
        "  labore et dolore magna aliqua.",
        "  Ut enim ad minim veniam, quis nostrud",
        "  exercitation ullamco aboris.\"\"\"",
    ],
    "\n",
)

@test startswith(split(lstrip(output), '\n'; limit=2)[2], prefix)

#=
try
    @info "These 4 failing tests don't have pretty diffs to display"
    @testset TestSetPlus "not-pretty" begin
        @testset "No pretty diff for matrices" begin
            @test [1 2; 3 4] == [1 4; 3 4]
        end
        @testset "don't diff non-equality" begin
            @test 1 > 2
        end
        @testset "don't diff non-comparisons" begin
            @test iseven(7)
        end
        @testset "errors don't have diffs either" begin
            throw(ErrorException("This test is supposed to throw an error"))
        end
    end
catch
end

@info "TestSetPlus{FallbackTestSet} test sets should exit when the first test fails"
@testset "TestSetPlus{FallbackTestSet} Tests" begin
    test_set_type = TestSetPlus{Test.FallbackTestSet}

    # Single-level test set
    err = nothing
    try
        @testset test_set_type "top-level tests" begin
            @test 1 == 2
            @test 1 == 1
        end
    catch err
    end

    @test err isa TestSetPlusException
    @test err.msg == "FallbackTestSetException occurred"

    # Nested test sets
    err = nothing
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
    catch err
    end

    @test err isa TestSetPlusException
    @test err.msg == "FallbackTestSetException occurred"

    # --- Nested DefaultTestSet tests
    #
    # * Tests Test.record(TestSetPlus{FallbackTestSet}, DefaultTestSet) needed for
    #   backward compatibility with Julia<=1.3.

    default_test_set = Test.DefaultTestSet

    # ------ DefaultTest nested under single TestSetPlus{FallbackTestSet} test set

    # With failing tests
    err = nothing
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
    catch err
    end

    @test err isa Test.FallbackTestSetException

    # With no failing tests
    err = nothing
    try
        @testset test_set_type "top-level tests" begin
            @testset default_test_set "No failing tests" begin
                @test 2 == 2
                @test 3 == 3
            end
        end
    catch err
    end

    @test err === nothing  # Note: isnothing() is not used for backward compatibility
                           # with Julia 1.0

    # ------ DefaultTest nested under multiple TestSetPlus{FallbackTestSet} test sets

    # With failing tests
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
    catch err
    end

    @test err isa TestSetPlusException
    @test err.msg == "FallbackTestSetException occurred"

    # With no failing tests
    err = nothing
    try
        @testset test_set_type "top-level tests" begin
            @testset test_set_type "2nd-level tests" begin
                @testset default_test_set "No failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        end
    catch err
    end

    @test err === nothing  # Note: isnothing() is not used for backward compatibility
                           # with Julia 1.0

end
=#
