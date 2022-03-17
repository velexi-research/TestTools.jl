```@meta
CurrentModule = TestTools
```

# TestTools.jl

## CLI Utilities

* jltest

TODO

* jlcodestyle

TODO

* jlcoverage

TODO

## Integration with `Pkg.test()`

* Add `test/runtests.jl` file containing the following lines.

  ```julia
  using TestTools: jltest
  jltest.autodetect()
  ```

  Note: `TestTools.jltest()` automatically detects and runs all tests in the current
  working directory.
