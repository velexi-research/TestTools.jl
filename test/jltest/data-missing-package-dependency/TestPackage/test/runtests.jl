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
Unit tests runner for TestPackage.jl package.
"""

# --- Set up Julia environment

test_tools_dir = joinpath(@__DIR__, "..", "..", "..", "..", "..")
push!(LOAD_PATH, test_tools_dir)

# --- Imports

# Standard library
using Test

# External packages
using TestTools: jltest

# Local package
include(joinpath(@__DIR__, "..", "src", "TestPackage.jl"))
using .TestPackage

# --- Run tests

jltest.run_tests(@__DIR__)

# --- Clean up

# Restore LOAD_PATH
filter!(x -> x != test_tools_dir, LOAD_PATH)
