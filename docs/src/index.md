```@meta
CurrentModule = TestTools
```

# TestTools.jl

TestTools is a collection of CLI utilities and APIs that simplifies code testing, coverage
analysis, and style checking.

--------------------------------------------------------------------------------------------

## Installation

* Start Julia in the default (global) environment.

  !!! note

      Installation in the default environment makes the CLI utilities available from within
      all projects.

* Install the `TestTools` package.

  ```julia
  pkg> add TestTools  # Press ']' to enter the Pkg REPL mode.
  ```

* Install the CLI utilities.

  ```julia
  julia> using TestTools; TestTools.install()
  ```

  By default, the CLI executables are installed to `~/.julia/bin`.

  * To install the CLI executables to a different location, set the `bin_dir` keyword
    argument to the path of the directory where the executables should be installed.

    ```julia
    julia> using TestTools; TestTools.install(; bin_dir=/PATH/TO/BIN/DIR)
    ```

  * To overwrite pre-existing CLI executables, set the `force` keyword argument to `true`.

    ```julia
    julia> using TestTools; TestTools.install(; force=true)
    ```

  * For other installation options, please refer to the documentation for the
    [`TestTools.install()`](@ref TestTools.install) method.

  !!! note

      _Uninstallation_. CLI utilities may be uninstalled by using the
      [`TestTools.uninstall()`](@ref TestTools.uninstall) method

      ```julia
      julia> using TestTools; TestTools.uninstall()
      ```

      By default, `uninstall()` removes CLI executables from `~/.julia/bin`. To uninstall
      CLI executables installed to a different location, set the `bin_dir` keyword argument
      to the path of the directory containing the executables to uninstall.

--------------------------------------------------------------------------------------------

## Usage

TestTools provides the following core components.

* CLI utilities: `jltest`, `jlcoverage`, `jlcodestyle`

* API: functions to management of unit tests (e.g. automatic detection of tests).

### CLI Utilities

#### jltest

Run unit tests in a single file.

```julia
$ jltest test/tests.jl
```

Run unit tests in a single file with fail-fast enabled (i.e., stop after first failing
test).

```julia
$ jltest -x test/tests.jl
```

Run all unit tests contained in a directory.

```julia
$ jltest test  # run all of the tests found in the `test` directory
```

#### jlcoverage

Generate a coverage report (after running unit tests while collecting coverage data).
```julia
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

#### jlcodestyle

Basic code style check (reformatting of source file disabled).

```julia
$ jlcodestyle src/TestTools.jl
No style errors found.

$ jlcodestyle examples/jlcodestyle/not-blue-style.jl
Style errors found. Files not modified.
```

Code style check with reformatting of source file enabled.

```julia
$ jlcodestyle --overwrite examples/jlcodestyle/not-blue-style.jl
Style errors found. Files modified to correct errors.
```

### Integration with `Pkg.test()`

* Add `test/runtests.jl` file containing the following lines.

  ```julia
  using TestTools: jltest
  jltest.run_test(@__DIR__)
  ```

  !!! note
      Passing `@__DIR__` as the first argument causes `jltest.run_tests()` to auto-detect
      all tests in the directory containing the `runtests.jl` file. For more details,
      please refer to the documentation for the
      [`jltest.run_tests()`](@ref TestTools.jltest.run_tests) method.

--------------------------------------------------------------------------------------------

## Acknowledgments

* TestTools borrows ideas (and some code) from the following excellent Julia packages.

  * [TestSetExtensions](https://github.com/ssfrr/TestSetExtensions.jl)

    * The `TestSetPlus` type and methods are based extensively on
      `TestsetExtensions.ExtendedTestSet`.

    * The `run_tests()` and `autodetect_tests()` methods are essentially a re-implementation
      and refactoring of the `TestsetExtensions.@includetests` macro as methods.

  * [SafeTestsets](https://github.com/YingboMa/SafeTestsets.jl)

    * The strategy for isolating tests came from the `SafeTestsets.@safetestset` macro.

* TestTools was inspired by analogous code testing packages in the Python ecosystem:

  * [pytest](https://docs.pytest.org/en/latest/)

  * [coverage](https://coverage.readthedocs.io/en/latest/)

  * [pycodestyle](https://pycodestyle.pycqa.org/en/latest/)
