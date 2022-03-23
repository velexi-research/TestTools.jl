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
Example Julia source file in YASStyle format.
"""

# --- Exports

export factorial, add_one

# --- Imports

using Pkg

# --- Types

struct A
    field1::Any
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
