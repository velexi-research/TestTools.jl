"""
Failing TestSetPlus test: check behavior for thrown Exception

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

@testset TestSetPlus "TestSetPlus: Exception test" begin
    throw(ErrorException("This test is supposed to throw an error"))
end
