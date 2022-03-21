```@meta
CurrentModule = TestTools
```

# TestTools.jl

[TestTools.jl](https://github.com/velexi-corporation/TestTools.jl)
is a collection of CLI tools and APIs that simplifies code testing, coverage analysis, and
style checking.

TestTools provides the following core components.

* CLI tools: `jltest`, `jlcoverage`, `jlcodestyle`

* API: functions to management of unit tests (e.g. automatic detection of tests).

--------------------------------------------------------------------------------------------

## CLI Tools

### jltest

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
$ jltest test
```

Display all command-line options.

```julia
$ jltest --help
```

### jlcoverage

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

Display all command-line options.

```julia
$ jlcoverage --help
```

### jlcodestyle

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

Display all command-line options.

```julia
$ jlcodestyle --help
```

--------------------------------------------------------------------------------------------

## Integration with `Pkg.test()`

When using `Pkg.test()` to run tests, TestTools makes it easy to automatically gather and
run all tests within the `test` directory (including subdirectories). Simply, create a
`test/runtests.jl` file containing the following lines.

```julia
using TestTools: jltest
jltest.run_test(@__DIR__)
```

!!! note
    Passing `@__DIR__` as the first argument causes `jltest.run_tests()` to auto-detect
    all tests in the directory containing the `runtests.jl` file. To run tests that
    reside in a different directory, replace `@__DIR__` with the path to the directory
    containing the tests. For more details, please refer to the documentation for the
    [`jltest.run_tests()`](@ref TestTools.jltest.run_tests) method.
