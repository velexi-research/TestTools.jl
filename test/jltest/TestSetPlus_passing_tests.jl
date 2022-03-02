"""
TODO
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
