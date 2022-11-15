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
Unit tests for the isolated test module constructed in the `run_all_tests()` method defined
in `jltest/utils.jl`.
"""

# --- Imports

# Standard library
using Test

# External packages
using Suppressor: @capture_out

# --- Tests

@testset "`include` is functional" begin
    # Check that the testing module defines :include
    @test :include in names(@__MODULE__; all=true)

    # Exercise `include()` and check results
    output = strip(@capture_out begin
        @testset begin
            include(joinpath("data-basic-tests", "some_tests.jl"))
        end
    end)
    @test output == ".."
end

@testset "`eval` is functional" begin
    # Exercise `@eval` macro and check results
    output = strip(@capture_out begin
        @testset begin
            @eval println(1 + 1)
        end
    end)

    @test output == "2"

    # Exercise `Base.eval()` and check results
    output = strip(@capture_out begin
        @testset begin
            @eval println(2 + 2)
            eval(:(println(3 + 3)))
            Base.eval(:(println(4 + 4)))
        end
    end)

    @test output == "4\n6\n8"

    # Exercise `Core.eval()` and check results
    output = strip(@capture_out begin
        @testset begin
            eval(@__MODULE__, :(println(5 + 5)))
            Core.eval(@__MODULE__, :(println(6 + 6)))
        end
    end)

    @test output == "10\n12"
end
