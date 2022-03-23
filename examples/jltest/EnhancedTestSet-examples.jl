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
Examples that demonstrate the diffs reported by EnhancedTestSet

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
using TestTools.jltest: EnhancedTestSet

# --- Tests

@testset EnhancedTestSet "Diff Examples" begin
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
