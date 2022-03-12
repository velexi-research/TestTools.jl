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

using Logging
using Test

# --- Tests

@testset "@warn message tests" begin
    @warn "Single line @warn message test"
    @warn """
          Multi-line @warn message test.
          Second line.
          Third line.
          """
end
@testset "@info message tests" begin
    @info "Single line @info message test"
    @info """
          Multi-line @info message test.
          Second line.
          Third line.
          """
end

@testset "@debug message tests" begin
    @debug "Single line @debug message test"
    @debug """
           Multi-line @debug message test.
           Second line.
           Third line.
           """
end
