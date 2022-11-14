# FAQ

* How are `jlcoverage` and `jlcodestyle` different than directly using the `Coverage`,
  `CoverageTools`, or `JuliaFormatter` packages?

  `TestTools` provides CLI tools that wrap functionality in the Julia packages that it
  depends on. Some trade-offs of using the `TestTools` CLI tools rather than directly
  calling package functions include:

    * Pros
        * Less typing when running from the shell
        * Combines useful sequences of package functions
        * Easier to set commonly used options
        * Shorter runtime (due to CLI-tuned compiler options)

    * Cons
        * Inconvenient to use from the Julia REPL
        * Does not cover all of the combinations of package functions
        * Does not cover all options available through package functions
        * Longer runtime (depends on compiler options used to start Julia REPL)

* What is the difference between `jlcodestyle` and `JuliaFormatter`'s `format.jl` CLI tool?

    * Method for specifying style
        * `jlcodestyle`: style level -- Blue vs YAS vs Default
        * `format.jl`: line level (e.g., number of spaces to use for indentation)

    * File overwriting behavior
        * `jlcodestyle`: by default, files are not overwritten. There is a command-line
          option enable file overwriting.

        * `format.jl`: always overwrites files

    * Performance
        * `jlcodestyle`: faster startup through the use of tuned Julia command-line options
        * `format.jl`: no command-line option tuning to reduce startup time
