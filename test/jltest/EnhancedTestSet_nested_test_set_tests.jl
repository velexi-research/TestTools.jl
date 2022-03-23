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

This set of unit tests checks the behavior of `EnhancedTestSet` with nested test sets.

Notes
-----
* For the unit tests in this files, failures and errors are expected.
"""

# --- Imports

# Standard library
using Test
using Test: DefaultTestSet

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

# ------ Failing tests with diffs

# Nested inherited test set
output = strip(
    @capture_out begin
        @testset EnhancedTestSet "EnhancedTestSet: nested inherited EnhancedTestSet" begin
            @testset "Nested Inherited Test Set" begin
                @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
            end
        end
    end
)

expected_prefix = strip("""
                  =====================================================
                  Nested Inherited Test Set: Test Failed
                    Expression: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]

                    Diff:
                  [3, 5, 6, 1, (-)6, (+)9, 8]
                  """)
@test startswith(output, expected_prefix)

# Nested DefaultTestSet
output = strip(@capture_out begin
    @testset EnhancedTestSet "EnhancedTestSet: nested DefaultTestSet" begin
        @testset DefaultTestSet "DefaultTestSet Nested in EnhancedTestSet" begin
            @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
        end
    end
end)

expected_prefix = strip(
    """
    DefaultTestSet Nested in EnhancedTestSet: Test Failed at $(@__FILE__):66
      Expression: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
       Evaluated: [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
    Stacktrace:
    """
)
@test startswith(output, expected_prefix)

# --- Emit message about expected failures and errors

println()
@info "For $(basename(@__FILE__)), 2 failures and 0 error are expected."
