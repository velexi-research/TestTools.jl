# Acknowledegments

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
