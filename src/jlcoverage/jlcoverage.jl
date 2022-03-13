"""
The `jlcoverage` module provides support for analyzing code coverage of unit tests.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
module jlcoverage

# API
include("utils.jl")

# CLI
include("cli/cli.jl")

end  # End of jlcoverage module
