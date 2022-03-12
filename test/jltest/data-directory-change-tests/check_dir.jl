"""
Unit tests to test methods in `jltest/utils.jl`

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

using Test

# --- Tests

@testset "check directory" begin
    expected_contents = Set(["change_dir.jl", "check_dir.jl", "subdir"])
    contents = Set(filter(x -> !startswith(x, "."), readdir()))
    @test contents == expected_contents
end
