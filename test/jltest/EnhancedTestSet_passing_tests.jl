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
Unit tests for the `EnhancedTestSet` type.

This set of unit tests checks the behavior of `EnhancedTestSet` for passing tests.
"""

# --- Imports

# Standard library
using Test

# External packages
using Suppressor

# Local modules
using TestTools.jltest

# --- Tests

@testset EnhancedTestSet "EnhancedTestSet: Check output dots" begin
    output = @capture_out begin
        @testset EnhancedTestSet "top-level tests" begin
            @testset "2nd-level tests 1" begin
                @test true
                @test 1 == 1
            end
            @testset "2nd-level tests 2" begin
                @test true
                @test 1 == 1
            end
        end
    end

    @test output == "...."
end
