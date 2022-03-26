# TestTools.jl

[TestTools.jl](https://github.com/velexi-corporation/TestTools.jl)
is a collection of CLI tools and APIs that simplifies code testing, coverage analysis, and
style checking.

TestTools provides the following core components.

* CLI tools: [`jltest`](@ref jltest-cli), [`jlcoverage`](@ref jlcoverage-cli),
  [`jlcodestyle`](@ref jlcodestyle-cli)

* API: functions and types to support unit testing (e.g. enhanced test sets and
  auto-detection of tests) and code coverage analysis.

--------------------------------------------------------------------------------------------

## Why TestTools.jl?

* Easy-to-use (and fast) CLI tools for testing

* Compatible with `Pkg.test()`

* Enhanced test set functionality – diffs for failed comparisons and fail-fast support

* Noninvasive – introduces no package-level dependencies

--------------------------------------------------------------------------------------------

## CLI Tools

!!! note
    Because they have been configured to eliminate unnecessary compiler optimizations, the
    TestTools CLI utilities often run faster than calling the functions they rely on from
    the Julia REPL.

### [`jltest`](@id jltest-cli)

Run unit tests in a single file.

```shell
$ jltest test/tests.jl
```

Run all unit tests contained in a directory.

```shell
$ jltest test/
```

Run unit tests with fail-fast enabled (i.e., halt testing after first failing test).

```shell
$ jltest -x test/tests.jl  # short option

$ jltest --fail-fast test/tests.jl  # long option
```

Display help and usage messages.

```shell
$ jltest -h  # short option

$ jltest --help  # long option
```

!!! warning "Can't turn off fail-fast?"
    When the `JLTEST_FAIL_FAST` environment variable is set to `true`, fail-fast is always
    enabled (even if `jltest` is run without the fail-fast option or the `test_set_type`
    keyword argument of `jltest.run_tests()` is set to a non-fail-fast test set type). If
    fail-fast mode seems to be permanently enabled, check to make sure the
    `JLTEST_FAIL_FAST` environment variable has not been accidentally set to `true`.

### [`jlcoverage`](@id jlcoverage-cli)

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

Display help and usage messages.

```shell
$ jlcoverage -h  # short option

$ jlcoverage --help  # long option
```

### [`jlcodestyle`](@id jlcodestyle-cli)

Run basic code style check (reformatting of source file disabled).

```shell
$ jlcodestyle src/TestTools.jl

$ jlcodestyle examples/jlcodestyle/not-blue-style.jl
Style errors found. Files not modified.
```

!!! note
    No output is displayed when there are no style errors. To display a status message, use
    the `-v` or `--verbose` command-line option.

    ```shell
    $ jlcodestyle -v src/TestTools.jl
    [ Info: Style = BlueStyle
    [ Info: Overwrite = false
    Formatting src/TestTools.jl

    No style errors found.
    ```

Run code style check with reformatting of source file enabled.

```shell
$ jlcodestyle --overwrite examples/jlcodestyle/not-blue-style.jl
Style errors found. Files modified to correct errors.
```

Run code style check with an explicitly selected style.

```shell
$ jlcodestyle -s yas examples/jlcodestyle/not-yas-style.jl
Style errors found. Files not modified.
```

Display help and usage messages.

```shell
$ jlcodestyle -h  # short option

$ jlcodestyle --help  # long option
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
    Passing `@__DIR__` as the first argument causes
    [`jltest.run_tests()`](@ref TestTools.jltest.run_tests) to auto-detect all tests in
    the directory containing the `runtests.jl` file. To run tests that reside in a
    different directory, replace `@__DIR__` with the path to the directory containing the
    tests. For more details, please refer to the documentation for the
    [`jltest.run_tests()`](@ref TestTools.jltest.run_tests) method.

!!! tip
    When running tests using `Pkg.test()`, enable fail-fast mode by setting the
    `JLTEST_FAIL_FAST` environment variable to `true`.

--------------------------------------------------------------------------------------------

## [`EnhancedTestSet`](@ref TestTools.jltest.EnhancedTestSet) Functionality

TestTools runs tests within an [`EnhancedTestSet`](@ref TestTools.jltest.EnhancedTestSet),
which augments the `DefaultTestSet` with the following functionality:

* display diffs for failed comparison tests (when possible),

* support fail-fast (i.e., halt testing at first failure), and

* display progress dots.

!!! tip
    No special effort is required to benefit from these enhancements. Simply use the
    `@testset` macro _without expicitly specifying the test set type_ (which is the easiest
    way to use `@testset` anyways). By default, `@testset` inherits the test set type, so
    tests run using either the `jltest` CLI tool or
    [`jltest.run_tests()`](@ref TestTools.jltest.run_tests) will automatically inherit the
    [`EnhancedTestSet`](@ref TestTools.jltest.EnhancedTestSet) functionality.

!!! note
    When `@testset` is invoked with an explicitly specified test set type, diffs are no
    longer displayed, but fail-fast still works.

--------------------------------------------------------------------------------------------

## Noninvasive

Using the TestTools CLI utilities within a Julia project _does not_ require the addition
of TestTools as a dependency for the project.

!!! note
    Depending on how unit tests are organized, the `test` environment of a Julia package
    might have TestTools as a dependency even though the package itself does not have
    TestTools as a dependency.

!!! note
    To be noninvasive, TestTools must be installed in the default (global) environment.
