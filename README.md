TestTools.jl (0.1.0)
====================

![build](https://github.com/velexi-corporation/TestTools.jl/actions/workflows/build.yml/badge.svg)
![build-dev](https://github.com/velexi-corporation/TestTools.jl/actions/workflows/build-dev.yml/badge.svg)
![codecov](https://github.com/velexi-corporation/TestTools.jl/actions/workflows/codecov/badge.svg)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/velexi-corporation/TestTools.jl/issues)


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
