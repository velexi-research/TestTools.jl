Testing TestTools
=================

Unit tests may be run using any of the following methods:

* from the shell using the Make target

  ```shell
  $ make test
  ```

* from the Julia REPL

  * without collection of coverage data

    ```julia
    import Pkg; Pkg.test("TestTools")
    ```

  * with collection of coverage data

    ```julia
    import Pkg; Pkg.test("TestTools"; coverage=true)
    ```

* from the shell using `jltest`

  ```shell
  $ jltest -W test/runtests.jl
  ```

  When using `jltest` to run the unit tests, note that the `-W` or `--no-wrapper` option
  is required for the tests that check the output failing tests to work correctly.

  __Note__. Use this method to test the outcome of the unit tests when they are run by the
  `julia-actions/julia-runtest` GitHub Action.
