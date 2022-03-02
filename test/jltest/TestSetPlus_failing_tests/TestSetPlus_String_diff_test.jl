"""
TODO
"""
# --- Imports

# Standard library
using Test

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "TestSetPlus: String diff test" begin
    @test """Lorem ipsum dolor sit amet,
             consectetur adipiscing elit, sed do
             eiusmod tempor incididunt ut
             labore et dolore magna aliqua.
             Ut enim ad minim veniam, quis nostrud
             exercitation ullamco aboris.""" ==
          """Lorem ipsum dolor sit amet,
             consectetur adipiscing elit, sed do
             eiusmod temper incididunt ut
             labore et dolore magna aliqua.
             Ut enim ad minim veniam, quis nostrud
             exercitation ullamco aboris."""
end
