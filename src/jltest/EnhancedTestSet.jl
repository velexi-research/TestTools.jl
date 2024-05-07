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
export get_wrapped_test_set_type

# --- Imports

# Standard library
using Test: Test
using Test: AbstractTestSet, DefaultTestSet, FallbackTestSet

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

    * one when T is a DefaultTestSet

    * one when T is a FallbackTest
    """
    function EnhancedTestSet{DefaultTestSet}(desc; kwargs...)
        # Get keyword arguments that are inherited from the parent test set
        if isempty(kwargs)
            kwargs = Dict()
        end
        if !(:verbose in keys(kwargs))
            parent_ts = Test.get_testset()
            if parent_ts isa DefaultTestSet
                kwargs[:verbose] = parent_ts.verbose
            elseif parent_ts isa EnhancedTestSet{DefaultTestSet}
                kwargs[:verbose] = parent_ts.wrapped.verbose
            end
        end

        return new(DefaultTestSet(desc; kwargs...))
    end

    EnhancedTestSet{FallbackTestSet}(desc; kwargs...) = new(FallbackTestSet())
end

struct EnhancedTestSetException <: Exception
    msg::String
end

# --- Functions/Methods

# Helper methods copied from Test.jl (Julia v1.10)
extract_file(source::LineNumberNode) = extract_file(source.file)
extract_file(file::Symbol) = string(file)
extract_file(::Nothing) = nothing

"""
    EnhancedTestSet(description::AbstractString; kwargs...)

Construct an EnhancedTestSet with the specified `description`.

# Keyword Arguments

* `wrap::Type{<:AbstractTestSet}`: test set type to wrap. Default: `DefaultTestSet`
"""
function EnhancedTestSet(
    description::AbstractString; wrap::Type{<:AbstractTestSet}=DefaultTestSet, kwargs...
)
    return EnhancedTestSet{wrap}(description; kwargs...)
end

function Test.record(ts::EnhancedTestSet{T}, res::Test.Fail) where {T}
    println("\n=====================================================")
    Test.record(ts.wrapped, res)

    return ts
end

# When recording DefaultTestSet results to an EnhancedTestSet{FallbackTestSet},
# throw an exception if there are any failures or errors in the DefaultTestSet.
function Test.record(ts::EnhancedTestSet{FallbackTestSet}, res::DefaultTestSet)
    # Check for failures and errors
    passes, fails, errors, broken, _, _, _, _ = Test.get_test_counts(res)
    if (fails > 0) || (errors > 0)
        throw(
            EnhancedTestSetException(
                "Failure or error occurred in DefaultTestSet nested within FallbackTestSet."
            ),
        )
    end

    return ts
end

function Test.record(ts::EnhancedTestSet{DefaultTestSet}, res::Test.Fail)
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

        if VERSION < v"1.10-"
            Base.show_backtrace(stdout, Test.scrub_backtrace(backtrace()))
        else
            Base.show_backtrace(
                stdout,
                Test.scrub_backtrace(
                    backtrace(), ts.wrapped.file, extract_file(res.source)
                ),
            )
        end

        println("\n=====================================================")
    end
    push!(ts.wrapped.results, res)
    return ts, backtrace()
end

function Test.record(ts::EnhancedTestSet{T}, res::Test.Error) where {T}
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

    return ts
end

function Test.record(ts::EnhancedTestSet{T}, res::Test.Pass) where {T}
    printstyled("."; color=:green)
    Test.record(ts.wrapped, res)
    return ts
end

Test.record(ts::EnhancedTestSet{T}, res) where {T} = Test.record(ts.wrapped, res)

function Test.finish(ts::EnhancedTestSet{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    Test.finish(ts.wrapped)
    return ts
end

"""
    get_wrapped_test_set_type(ts::EnhancedTestSet{T}

Return type of test set wrapped by `ts`.
"""
get_wrapped_test_set_type(ts::Type{EnhancedTestSet{T}}) where {T} = T
