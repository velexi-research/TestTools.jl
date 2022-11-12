#   Copyright 2022 Velexi Corporation
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
jltest/EnhancedTestSet.jl extend the types and methods that support unit testing.

Acknowledgements
----------------
* Much of the core functionality of the `EnhancedTestSet` type (and associated methods)
  were taken directly from the TestSetExtensions package developed by Spencer Russell and
  his collaborators (https://github.com/ssfrr/TestSetExtensions.jl). `EnhancedTestSet`
  builds upon the foundation of `ExtendedTestSet` to add support for fail-fast
  functionality.
"""

# --- Exports

export EnhancedTestSet, EnhancedTestSetException

# --- Imports

# Standard library
using Test: Test
using Test: AbstractTestSet, DefaultTestSet, FallbackTestSet
using Test: Result, Fail, Error, Pass

# External Packages
using DeepDiffs
using Distributed

# --- Types

"""
    struct EnhancedTestSet{T<:AbstractTestSet} <: AbstractTestSet

Extension of the `AbstracctTestSet` type that provides the following functionality:

* display diffs (when available) for comparison test failures;

* support fail-fast (i.e., stop testing at first failure).
"""
struct EnhancedTestSet{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T

    """
    Two inner constructors

    * one for subtypes of AbstractTestSet that possess a constructor with a `desc` argument

    * one for subtypes of AbstractTestSet that do not possess a constructor with a `desc`
      argument
    """
    EnhancedTestSet{T}(desc) where {T} = new(T(desc))

    EnhancedTestSet{FallbackTestSet}(desc) = new(FallbackTestSet())
end

struct EnhancedTestSetException <: Exception
    msg::String
end

# --- Functions/Methods

"""
    EnhancedTestSet(description::AbstractString; <keyword arguments>)

Construct an EnhancedTestSet with the specified `description`.

# Keyword Arguments

* `wrap::Type{<:AbstractTestSet}`: test set type to wrap. Default: `DefaultTestSet`
"""
function EnhancedTestSet(
    description::AbstractString; wrap::Type{<:AbstractTestSet}=DefaultTestSet
)
    return EnhancedTestSet{wrap}(description)
end

function Test.record(ts::EnhancedTestSet{T}, res::Fail) where {T}
    println("\n=====================================================")
    Test.record(ts.wrapped, res)

    return nothing
end

function Test.record(ts::EnhancedTestSet{DefaultTestSet}, res::Fail)
    if Distributed.myid() == 1
        println("\n=====================================================")
        printstyled(ts.wrapped.description, ": "; color=:white)

        if res.test_type === :test
            try
                test_expr = if isa(res.data, Expr)
                    res.data
                elseif isa(res.data, String)
                    Meta.parse(res.data)
                end

                if test_expr.head === :call && test_expr.args[1] === Symbol("==")
                    test_expr_diff =
                        if isa(test_expr.args[2], String) && isa(test_expr.args[3], String)
                            deepdiff(test_expr.args[2], test_expr.args[3])
                        elseif test_expr.args[2].head === :vect &&
                            test_expr.args[3].head === :vect
                            deepdiff(test_expr.args[2].args, test_expr.args[3].args)
                        elseif test_expr.args[2].head === :call &&
                            test_expr.args[3].head === :call &&
                            test_expr.args[2].args[1].head === :curly &&
                            test_expr.args[3].args[1].head === :curly
                            deepdiff(
                                Base.eval(test_expr.args[2].args),
                                Base.eval(test_expr.args[3].args),
                            )
                        end

                    if !isa(test_expr_diff, DeepDiffs.SimpleDiff)
                        # The test was an comparison between things we can diff,
                        # so display the diff
                        printstyled("Test Failed\n"; bold=true, color=Base.error_color())
                        println("  Expression: ", res.orig_expr)
                        printstyled("\n  Diff:\n"; color=Base.info_color())
                        println(test_expr_diff)
                    else
                        # Fallback to the default printing if there is no diff.
                        println(res)
                    end
                else
                    # Fallback to the default printing for non-equality comparisons
                    println(res)
                end
            catch ex
                println(res)
            end
        else
            # Fallback to the default printing if test_type != :test
            println(res)
        end

        Base.show_backtrace(stdout, Test.scrub_backtrace(backtrace()))
        println("\n=====================================================")
    end
    push!(ts.wrapped.results, res)
    return res, backtrace()
end

function Test.record(ts::EnhancedTestSet{T}, res::Error) where {T}
    # Ignore errors generated from failed FallbackTestSet
    if occursin(r"^(Test.)*FallbackTestSetException", res.value) || (
        occursin(r"^(TestTools.jltest.)*EnhancedTestSetException", res.value) &&
        occursin("FallbackTestSetException occurred", res.value)
    )
        throw(EnhancedTestSetException("FallbackTestSetException occurred"))
    end

    println("\n=====================================================")
    Test.record(ts.wrapped, res)
    println("=====================================================")
    return nothing
end

function Test.record(ts::EnhancedTestSet{T}, res::Pass) where {T}
    printstyled("."; color=:green)
    Test.record(ts.wrapped, res)
    return res
end

Test.record(ts::EnhancedTestSet{T}, res) where {T} = Test.record(ts.wrapped, res)

function Test.finish(ts::EnhancedTestSet{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    Test.finish(ts.wrapped)
    return nothing
end
