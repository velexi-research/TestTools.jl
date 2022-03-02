# --- User Parameters


# --- Internal Parameters


# --- Targets

# Default target
all: test

test check:
	@echo Preparations
	find . -name "*.jl.*.cov" -exec rm -f {} \;  # Remove old coverage files
	@echo
	@echo Unit Tests
	julia --color=yes -e 'import Pkg; Pkg.test(coverage=true)'
	@echo
	@echo Code Coverage
	@jlcoverage

# Maintenance
clean:
	find . -name "tmp.init-pkg.*" -exec rm -rf {} \;  # init-pkg.jl files
	find . -name "*.jl.*.cov" -exec rm -f {} \;  # Coverage.jl files
	find . -name "*.jl.*.mem" -exec rm -f {} \;  # Coverage.jl files

spotless: clean
	find . -name "Manifest.toml" -exec rm -rf {} \;  # Manifest.toml files

# Setup Julia
setup:
	julia --project=`pwd`/bin --startup-file=no \
		-e 'import Pkg; Pkg.instantiate()'
	julia --project=`pwd`/test --startup-file=no \
		-e 'import Pkg; Pkg.instantiate()'

# Phony Targets
.PHONY: all clean setup \
        test check
