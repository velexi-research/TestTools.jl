"""
The TestTools package provides support for testing and code quality CLIs.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""

module TestTools

# --- Package Metadata

using TOML: TOML
const VERSION = TOML.parsefile(joinpath(pkgdir(@__MODULE__), "Project.toml"))["version"]

# --- Submodules

# jlcodestyle
include("jlcodestyle/jlcodestyle.jl")

# jlcoverage
include("jlcoverage/jlcoverage.jl")

# jltest
include("jltest/jltest.jl")

# --- Package management functions

include("pkg.jl")

end  # End of TestTools module
