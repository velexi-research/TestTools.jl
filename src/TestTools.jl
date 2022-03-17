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
The TestTools package provides support for testing and code quality CLIs.
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
