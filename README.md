TestTools.jl
============

[------------------------------------ BADGES: BEGIN ------------------------------------]: #

<table>
  <tr>
    <td>Documentation</td>
    <td>
      Coming Soon!
      <!--
      <a href=""><img style="vertical-align: bottom;" src="https://img.shields.io/badge/docs-stable-blue.svg"/></a>
      -->
    </td>
  </tr>

  <tr>
    <td>Build Status</td>
    <td>
      <a href="https://github.com/velexi-corporation/TestTools.jl/actions/workflows/CI.yml"><img style="vertical-align: bottom;" src="https://github.com/velexi-corporation/TestTools.jl/actions/workflows/CI.yml/badge.svg"/></a>
      <a href="https://codecov.io/gh/velexi-corporation/TestTools.jl"><img style="vertical-align: bottom;" src="https://codecov.io/gh/velexi-corporation/TestTools.jl/branch/main/graph/badge.svg?token=LW2DS0JUWF"/></a>
    </td>
  </tr>

  <!-- Miscellaneous Badges -->
  <tr>
    <td colspan=2 align="center">
      <a href="https://github.com/velexi-corporation/TestTools.jl/issues"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"/></a>
      <a href="https://github.com/invenia/BlueStyle"><img style="vertical-align: bottom;" src="https://img.shields.io/badge/code%20style-blue-4495d1.svg"/></a>
      <a href="http://hits.dwyl.com/velexi/TestToolsjl"><img style="vertical-align: bottom;" src="https://hits.dwyl.com/velexi/TestToolsjl.svg?style=flat-square&show=unique"/></a>
    </td>
  </tr>
</table>

[------------------------------------- BADGES: END -------------------------------------]: #

TestTools is a collection of CLI utilities and APIs that simplifies code testing, coverage
analysis, and style checking. Our goal is to make it a joy to do software testing (or at
least save effort and keystrokes).

## Quick Start

* Start Julia in the default (global) environment.

  * __Note__: installation in the default environment makes the CLI utilities available
    from within all projects.

* Install the `TestTools` CLI utilities.

  ```jl
  pkg> add TestTools  # Press ']' to enter the Pkg REPL mode.
  ```

* Install the CLI utilities (to `~/.julia/bin`).

  ```jl
  julia> using TestTools; TestTools.install()
  ```

## Usage

### CLI Utilities

#### `jltest`

Run unit tests in a single file.

```jl
$ jltest test/tests.jl
```

Run unit tests in a single file with fail-fast enabled (i.e., stop after first failing
test).

```jl
$ jltest -x test/tests.jl
```

Run unit tests contained in a directory.

```jl
$ jltest test  # run all of the tests found in the `test` directory
```

#### `jlcoverage`

Generate a coverage report (after running unit tests while collecting coverage data).
```jl
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

Basic code style check (reformatting of source file disabled).

```jl
$ jlcodestyle src/TestTools.jl
No style errors found.

$ jlcodestyle examples/jlcodestyle/not-blue-style.jl
Style errors found. Files not modified.
```

Code style check with reformatting of source file enabled.

```jl
$ jlcodestyle --overwrite examples/jlcodestyle/not-blue-style.jl
Style errors found. Files modified to correct errors.
```
