"""
Unit tests for the `TestSetPlus` type.

This set of unit tests checks the behavior of `TestSetPlus` for passing tests.

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

@testset TestSetPlus "TestSetPlus: Check output dots" begin
    output = @capture_out begin
        @testset TestSetPlus "top-level tests" begin
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
