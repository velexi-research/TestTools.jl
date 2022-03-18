"""
Examples that demonstrate the diffs reported by TestSetPlus

Acknowledgements
----------------
* This example was taken more or less directly from taken directly from the
  TestSetExtensions package developed by Spencer Russell and his collaborators
  (https://github.com/ssfrr/TestSetExtensions.jl).
"""
# --- Imports

# Standard library
using Test

# Local modules
using TestTools.jltest: TestSetPlus

# --- Tests

@testset TestSetPlus "Diff Examples" begin
    @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]

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

    @test Dict(:foo => "bar", :baz => [1, 4, 5], :biz => nothing) ==
        Dict(:baz => [1, 7, 5], :biz => 42)
end
