# Installation

* Start Julia in the default (global) environment.

  !!! note

      Installation in the default environment makes the CLI tools available from within
      all projects.

* Install the `TestTools` package.

  ```julia
  pkg> add TestTools  # Press ']' to enter the Pkg REPL mode.
  ```

* Install the CLI tools.

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

## Uninstallation

CLI executables may be uninstalled by using the
[`TestTools.uninstall()`](@ref TestTools.uninstall) method.

```julia
julia> using TestTools; TestTools.uninstall()
```

By default, `uninstall()` removes CLI executables from `~/.julia/bin`. To uninstall
CLI executables installed to a different location, set the `bin_dir` keyword argument
to the path of the directory containing the executables to uninstall.
