"""
Unit test runner for the TestPackage.jl package.

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

# Local package
include(joinpath(dirname(@__FILE__), "..", "src", "TestPackage.jl"))
using .TestPackage

@testset "TestPackage tests" begin
    @test add_one(1) == 2
    @test add_two(1) == 3
end
