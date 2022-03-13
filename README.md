TestTools.jl (0.1.0)
====================

[![Tests](https://github.com/velexi-corporation/TestTools.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/velexi-corporation/TestTools.jl/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/velexi-corporation/TestTools.jl/branch/main/graph/badge.svg?token=LW2DS0JUWF)](https://codecov.io/gh/velexi-corporation/TestTools.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![HitCount](https://hits.dwyl.com/velexi/TestToolsjl.svg?style=flat-square&show=unique)](http://hits.dwyl.com/velexi/TestToolsjl)[![Contributions welcome!](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/velexi-corporation/TestTools.jl/issues)

------------------------------------------------------------------------------

Contents
--------

1. [Overview][#1]

    1.1. [Package Contents][#1.1]

    1.2. [Software Dependencies][#1.2]

    1.3. [License][#1.3]

2. [Usage][#2]

3. [Known Issues][#3]

------------------------------------------------------------------------------

## 1. Overview

PLACEHOLDER

### 1.1. Package Contents

### 1.2. Software Dependencies

#### Base Requirements

* Julia (>=v1.6)

#### Julia Packages ####

See the `[deps]` section of the `Project.toml` and `test/Project.toml` files.

### 1.3. License

See the LICENSE file for copyright and license information.

### 1.4. Acknowledgements

* TestSetExtensions
  * https://github.com/ssfrr/TestSetExtensions.jl
    * TestSetPlus based on ExtendedTestSet.
    * Tests for TestSetPlus from TestSetExtensions.jl

------------------------------------------------------------------------------

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

------------------------------------------------------------------------------

## 3. Known Issues

PLACEHOLDER

------------------------------------------------------------------------------

[-----------------------------INTERNAL LINKS-----------------------------]: #

[#1]: #1-overview
[#1.1]: #11-package-contents
[#1.2]: #12-software-dependencies
[#1.3]: #13-license

[#2]: #2-usage

[#3]: #3-known-issues
