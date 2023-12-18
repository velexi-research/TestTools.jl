# TestTools

[------------------------------------ BADGES: BEGIN ------------------------------------]: #

<table>
  <tr>
    <td>Documentation</td>
    <td>
      <a href="https://velexi-research.github.io/TestTools.jl/dev/"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/docs-dev-blue.svg"/></a>
      <a href="https://velexi-research.github.io/TestTools.jl/stable/"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/docs-stable-blue.svg"/></a>
    </td>
  </tr>

  <tr>
    <td>Build Status</td>
    <td>
      <a href="https://github.com/velexi-research/TestTools.jl/actions/workflows/CI.yml"><img style="vertical-align: bottom;" src="https://github.com/velexi-research/TestTools.jl/actions/workflows/CI.yml/badge.svg"/></a>
      <a href="https://codecov.io/gh/velexi-research/TestTools.jl"><img style="vertical-align: bottom;" src="https://codecov.io/gh/velexi-research/TestTools.jl/branch/main/graph/badge.svg?token=LW2DS0JUWF"/></a>
    </td>
  </tr>

  <!-- Miscellaneous Badges -->
  <tr>
    <td colspan=2 align="center">
      <a href="https://github.com/velexi-research/TestTools.jl/issues"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"/></a>
      <a href="https://github.com/invenia/BlueStyle"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/code%20style-blue-4495d1.svg"/></a>
      <a href="http://hits.dwyl.com/velexi/TestToolsjl"><img style="vertical-align: bottom;" src="https://hits.dwyl.com/velexi/TestToolsjl.svg?style=flat-square&show=unique"/></a>
    </td>
  </tr>
</table>

[------------------------------------- BADGES: END -------------------------------------]: #

TestTools is a collection of CLI tools and APIs that simplifies code testing, coverage
analysis, and style checking for the Julia programming language. Our goal is to make it a
joy to do software testing (or at least save effort and keystrokes).


## Why TestTools?

* Easy-to-use (and fast) CLI tools for testing

* Compatible with `Pkg.test()`

* Enhanced test set functionality – diffs for failed comparisons and fail-fast support

* Noninvasive – introduces no package-level dependencies

## Quick Start

* Start Julia in the default (global) environment.

  * __Note__. Installation in the default environment makes the CLI tools available from
    within all projects.

* Install the `TestTools` package.

  ```julia
  pkg> add TestTools  # Press ']' to enter the Pkg REPL mode.
  ```

* Install the CLI tools (to `~/.julia/bin`).

  ```julia
  julia> using TestTools; TestTools.install()
  ```

## Usage

### CLI Utilities

#### `jltest`

Run unit tests in a single file.

```shell
$ jltest test/tests.jl
```

Run all unit tests contained in a directory.

```shell
$ jltest test/
```

Run unit tests with fail-fast enabled (i.e., halt testing after the first failing test).

```shell
$ jltest -x test/tests.jl
```

#### `jlcoverage`

Generate a coverage report (after running unit tests while collecting coverage data).

```shell
$ julia -e 'import Pkg; Pkg.test("TestTools"; coverage=true)'  # run unit tests

$ jlcoverage  # generate coverage report
-------------------------------------------------------------------------------
File                                  Lines of Code     Missed   Coverage
-------------------------------------------------------------------------------
src/TestTools.jl                                  0          0        N/A
src/jlcodestyle/cli/cli.jl                       34          0     100.0%
...
src/pkg.jl                                       42          3      92.9%
-------------------------------------------------------------------------------
TOTAL                                           289          7      97.6%
```

#### `jlcodestyle`

Run basic code style check (reformatting of source file disabled).

```shell
$ jlcodestyle src/TestTools.jl

$ jlcodestyle --verbose src/TestTools.jl
[ Info: Style = BlueStyle
[ Info: Overwrite = false
Formatting src/TestTools.jl

No style errors found.

$ jlcodestyle examples/jlcodestyle/not-blue-style.jl
Style errors found. Files not modified.
```

Run code style check with reformatting of source file enabled.

```shell
$ jlcodestyle --overwrite examples/jlcodestyle/not-blue-style.jl
Style errors found. Files modified to correct errors.
```

## Acknowledgements

* TestTools leverages several excellent Julia packages to support its core capabilities.

  * [Coverage](https://github.com/JuliaCI/Coverage.jl)

  * [CoverageTools](https://github.com/JuliaCI/CoverageTools.jl)

  * [JuliaFormatter](https://github.com/domluna/JuliaFormatter.jl)

* TestTools borrows ideas (and some code) from the following great Julia packages.

  * [TestSetExtensions](https://github.com/ssfrr/TestSetExtensions.jl)

    * The base code for `EnhancedTestSet` (which implements diffs for comparisons and
      progress dots) comes directly from `TestsetExtensions.ExtendedTestSet`.

    * The `run_tests()` and `find_tests()` methods are essentially a re-implementation
      and refactoring of the `TestsetExtensions.@includetests` macro as methods.

  * [SafeTestsets](https://github.com/YingboMa/SafeTestsets.jl)

    * The strategy for isolating tests came from the `SafeTestsets.@safetestset` macro.

  * [jlpkg](https://github.com/fredrikekre/jlpkg)

    * The strategy for installing CLI executables came from `jlpkg.install()`.

* TestTools was inspired by analogous code testing packages in the Python ecosystem:

  * [pytest](https://docs.pytest.org/en/latest/)

  * [coverage](https://coverage.readthedocs.io/en/latest/)

  * [pycodestyle](https://pycodestyle.pycqa.org/en/latest/)
