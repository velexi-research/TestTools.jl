# --- User Parameters


# --- Internal Parameters


# --- Targets

# Default target
all: test

test check:
	@echo Remove old coverage files
	julia --color=yes --compile=min -O0 -e 'using Coverage; clean_folder(".");'
	@echo
	@echo Unit Tests
	julia --color=yes -e 'import Pkg; Pkg.test("TestTools"; coverage=true)'
	@echo
	@echo Code Coverage
	@jlcoverage

# Maintenance
clean:
	find . -name "tmp.init-pkg.*" -exec rm -rf {} \;  # init-pkg.jl files
	julia --color=yes --compile=min -O0 -e 'using Coverage; clean_folder(".");'

spotless: clean
	find . -name "Manifest.toml" -exec rm -rf {} \;  # Manifest.toml files

# Setup Julia
setup:
	julia --project=`pwd`/test --startup-file=no \
		-e 'import Pkg; Pkg.instantiate()'

# Phony Targets
.PHONY: all clean setup \
        test check
