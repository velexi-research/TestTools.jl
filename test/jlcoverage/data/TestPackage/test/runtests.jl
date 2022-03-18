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
Unit test runner for the TestPackage.jl package.
"""

# --- Imports

# Standard library
using Test

# Local package
include(joinpath(@__DIR__, "..", "src", "TestPackage.jl"))
using .TestPackage

@testset "TestPackage tests" begin
    @test add_one(1) == 2
    @test add_two(1) == 3
end
