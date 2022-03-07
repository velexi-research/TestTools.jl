"""
Example Julia source file in BlueStyle format.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Exports

export factorial, add_one

# --- Imports

using Pkg

# --- Types

struct A
    field1
end

# --- Methods

"""
    factorial(n)

Return ``n!``
"""
function factorial(n)
    result = 1
    for i in 1:n
        result *= i
    end

    return result
end

"""
    add_one(x)

Return ``x+1``.
"""
add_one(x) = x + 1

"""
    print_hello()

Print "Hello, World!".
"""
function print_hello()
    println("Hello, World!")

    return nothing
end
