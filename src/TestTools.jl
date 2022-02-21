"""
The TestTools.jl module defines TestTools types and functions.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools package. It is subject to the license
terms in the LICENSE file found in the root directory of this distribution. No part of the
TestTools package, including this file, may be copied, modified, propagated, or distributed
except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
module TestTools

# jlcodestyle
include("jlcodestyle/cli.jl")

# jlcoverage
include("jlcoverage/utils.jl")
include("jlcoverage/cli.jl")

# jltest
include("jltest/TestSetPlus.jl")
include("jltest/utils.jl")
include("jltest/cli.jl")

end  # End of TestTools module
