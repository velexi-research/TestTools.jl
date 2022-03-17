```@meta
CurrentModule = TestTools
```

# TestTools.jl

Documentation for [TestTools](https://github.com/velexi-corporation/TestTools.jl).

```@contents
```

```@docs
TestTools.jltest.run_tests
```

```@index
```

- link to [TestTools.jl](@ref)
- link to [`TestTools.jltest.run_tests`](@ref)

```@autodocs
Modules = [TestTools]
```

<!--

## 1. Overview

PLACEHOLDER

### 1.1. Package Contents

### 1.4. Acknowledgements

* TestSetExtensions
  * https://github.com/ssfrr/TestSetExtensions.jl
    * TestSetPlus based on ExtendedTestSet.
    * Tests for TestSetPlus from TestSetExtensions.jl

* SafeTestsets
  * https://github.com/YingboMa/SafeTestsets.jl
    * Isolation of test files based on strategy used in SafeTestsets.

--------------------------------------------------------------------------------------------

## 2. Usage

### CLI Utilities

* jltest
* jlcodestyle
* jlcoverage

### Running tests via `Pkg.test()'`

* Add `test/runtests.jl` file containing the following lines.

```julia
using TestTools: jltest
jltest(; mod=PKG_NAME)
```

  Note: `TestTools.jltest()` automatically detects and runs all tests in the current
  working directory.

  * (BROKEN) it will also run doctests from the `PKG_NAME` module.

--------------------------------------------------------------------------------------------

## 3. Known Issues

* Incomplete and erroneous documentation. Updates coming soon!

--------------------------------------------------------------------------------------------
-->
