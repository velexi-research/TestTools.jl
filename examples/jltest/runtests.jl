"""
Example `runtests.jl` file that auto-detects unit tests within the directory containing
the `runtests.jl` file.
"""
# --- Imports

using TestTools: jltest

# --- Run tests

jltest.run_tests(@__DIR__)
