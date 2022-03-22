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
Unit tests for the `TestSetPlus` type.

This set of unit tests checks the output of `TestSetPlus` for failing tests.

Notes
-----
* For the unit tests in this files, failures and errors are expected.
"""

# --- Imports

# Standard library
using Test

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

# ------ Failing tests with diffs

# Array equality test
output = strip(@capture_out begin
    @testset TestSetPlus "TestSetPlus: Array equality test" begin
        @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
    end
end)

expected_prefix = strip("""
                  =====================================================
                  TestSetPlus: Array equality test: Test Failed
                    Expression: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]

                    Diff:
                  [3, 5, 6, 1, (-)6, (+)9, 8]
                  """)
@test startswith(output, expected_prefix)

# Dict equality test
output = strip(
    @capture_out begin
        @testset TestSetPlus "TestSetPlus: Dict equality test" begin
            @test Dict(:foo => "bar", :baz => [1, 4, 5], :biz => nothing) ==
                Dict(:baz => [1, 7, 5], :biz => 42)
        end
    end
)

expected_prefix = strip(
    """
=====================================================
TestSetPlus: Dict equality test: Test Failed
  Expression: Dict(:foo => \"bar\", :baz => [1, 4, 5], :biz => nothing) == Dict(:baz => [1, 7, 5], :biz => 42)

  Diff:
[Dict{Symbol, Any}, (-):biz => nothing, (-):baz => [1, 4, 5], (-):foo => \"bar\", (+):biz => 42, (+):baz => [1, 7, 5]]

""",
)

@test startswith(output, expected_prefix)

# String equality test
output = strip(
    @capture_out begin
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
)

expected_prefix = join(
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

@test startswith(output, expected_prefix)

# ------ Failing tests without diffs

# Boolean expression test
output = strip(@capture_out begin
    @testset TestSetPlus "TestSetPlus: Boolean expression test" begin
        @test iseven(7)
    end
end)

expected_prefix = strip("""
                  =====================================================
                  TestSetPlus: Boolean expression test: Test Failed at $(@__FILE__):132
                    Expression: iseven(7)

                  Stacktrace:

                  """)

@test startswith(output, expected_prefix)

# Exception test
output = strip(@capture_out begin
    @testset TestSetPlus "TestSetPlus: Exception test" begin
        throw(ErrorException("This test is supposed to throw an error"))
    end
end)

expected_prefix = strip("""
                  =====================================================
                  TestSetPlus: Exception test: Error During Test at $(@__FILE__):149
                    Got exception outside of a @test
                    This test is supposed to throw an error
                    Stacktrace:
                  """)

@test startswith(output, expected_prefix)

# Inequality test
output = strip(@capture_out begin
    @testset TestSetPlus "TestSetPlus: inequality test" begin
        @test 1 > 2
    end
end)

expected_prefix = strip("""
                  =====================================================
                  TestSetPlus: inequality test: Test Failed at $(@__FILE__):167
                    Expression: 1 > 2
                     Evaluated: 1 > 2

                  Stacktrace:
                  """)

@test startswith(output, expected_prefix)

# Matrix equality test
output = strip(@capture_out begin
    @testset TestSetPlus "TestSetPlus: Matrix equality test" begin
        @test [1 2; 3 4] == [1 4; 3 4]
    end
end)

expected_prefix = strip("""
                  =====================================================
                  TestSetPlus: Matrix equality test: Test Failed
                    Expression: [1 2; 3 4] == [1 4; 3 4]

                    Diff:
                  nothing
                  """)
@test startswith(output, expected_prefix)

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 6 failures and 1 error are expected."
