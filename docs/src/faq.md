# FAQ

* What is the difference between `jlcodestyle` and JuliaFormatter's `format.jl`?

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

