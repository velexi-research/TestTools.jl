By default, `jlcodestyle` applies the Blue style, so running the following command will
detect style errors:

```julia
$ jlcodestyle default-style.jl
```

With the `-o` or `--overwrite` option, the original file will be overwritten with a file
that has the style errors corrected.
