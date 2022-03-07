"""
Methods for the TestPackage package.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Exports

export add_one, add_two, add_three

# --- Methods

"""
    add_one(x)

Return ``x + 1``.
"""
add_one(x) = x + 1

"""
    add_two(x)

Return ``x + 2``.
"""
add_two(x) = x + 2

"""
    add_three(x)

Return ``x + 3``.
"""
add_three(x) = x + 3
