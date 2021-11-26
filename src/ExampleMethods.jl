"""
ExampleMethods.jl defines methods for the ExampleModule.jl module.

------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the {{ PKG_NAME }} package. It is
subject to the license terms in the LICENSE file found in the root directory
of this distribution. No part of the {{ PKG_NAME }} package, including this
file, may be copied, modified, propagated, or distributed except according to
the terms contained in the LICENSE file.
------------------------------------------------------------------------------
"""
# --- Exports

export say_hello, add_one

# --- Method definitions

"""
    say_hello(who::String)

Return "Hello, `who`".
"""
say_hello(who::String) = "Hello, $who"

"""
    add_one(x)

Return `x + 1`.
"""
add_one(x) = x + 1
