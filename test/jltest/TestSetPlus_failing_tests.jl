"""
Unit tests for the `TestSetPlus` type.

This set of unit tests checks the behavior of `TestSetPlus` for failing tests.

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

# --- Private helper functions

function check_expected_prefix(output::AbstractString, prefix::String)
    return startswith(lstrip(output), prefix)
end

# --- Tests

# ------ Failing tests with diffs

# Array equality test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: Array equality test" begin
        @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Array equality test: Test Failed",
        "  Expression: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]",
        "",
        "  Diff:",
        "[3, 5, 6, 1, (-)6, (+)9, 8]",
        "",
    ],
    "\n",
)
@test check_expected_prefix(output, prefix)

# Dict equality test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: Dict equality test" begin
        @test Dict(:foo => "bar", :baz => [1, 4, 5], :biz => nothing) ==
            Dict(:baz => [1, 7, 5], :biz => 42)
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Dict equality test: Test Failed",
        "  Expression: Dict(:foo => \"bar\", :baz => [1, 4, 5], :biz => nothing) " *
        "== Dict(:baz => [1, 7, 5], :biz => 42)",
        "",
        "  Diff:",
        "[Dict{Symbol, Any}, (-):biz => nothing, (-):baz => [1, 4, 5], " *
        "(-):foo => \"bar\", (+):biz => 42, (+):baz => [1, 7, 5]]",
        "",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)

# String equality test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: String equality test" begin
        @test """Lorem ipsum dolor sit amet,
                 consectetur adipiscing elit, sed do
                 eiusmod tempor incididunt ut
                 labore et dolore magna aliqua.
                 Ut enim ad minim veniam, quis nostrud
                 exercitation ullamco aboris.""" == """Lorem ipsum dolor sit amet,
                                                       consectetur adipiscing elit, sed do
                                                       eiusmod temper incididunt ut
                                                       labore et dolore magna aliqua.
                                                       Ut enim ad minim veniam, quis nostrud
                                                       exercitation ullamco aboris."""
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: String equality test: Test Failed",
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
        "",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)

# ------ Failing tests without diffs

# Boolean expression test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: Boolean expression test" begin
        @test iseven(7)
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Boolean expression test: Test Failed at $(@__FILE__):140",
        "  Expression: iseven(7)",
        "",
        "Stacktrace:",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)

# Exception test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: Exception test" begin
        throw(ErrorException("This test is supposed to throw an error"))
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Exception test: Error During Test at $(@__FILE__):162",
        "  Got exception outside of a @test",
        "  This test is supposed to throw an error",
        "  Stacktrace:",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)

# Inequality test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: inequality test" begin
        @test 1 > 2
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: inequality test: Test Failed at $(@__FILE__):187",
        "  Expression: 1 > 2",
        "   Evaluated: 1 > 2",
        "",
        "Stacktrace:",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)

# Matrix equality test
output = @capture_out begin
    @testset TestSetPlus "TestSetPlus: Matrix equality test" begin
        @test [1 2; 3 4] == [1 4; 3 4]
    end
end

prefix = join(
    [
        "=====================================================",
        "TestSetPlus: Matrix equality test: Test Failed",
        "  Expression: [1 2; 3 4] == [1 4; 3 4]",
        "",
        "  Diff:",
        "nothing",
    ],
    "\n",
)

@test check_expected_prefix(output, prefix)
