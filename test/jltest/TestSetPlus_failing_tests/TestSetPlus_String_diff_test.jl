"""
Failing TestSetPlus test: check behavior for failed String comparison

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

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "TestSetPlus: String diff test" begin
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
end
