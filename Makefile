# --- User Parameters


# --- Internal Parameters


# --- Targets

# Default target
all: test

test:
	@echo Remove old coverage files
	julia --color=yes --compile=min -O0 -e 'using Coverage; clean_folder(".");'
	@echo
	@echo Run tests
	julia --color=yes -e 'import Pkg; Pkg.test("TestTools"; coverage=true)'
	@echo
	@echo Generate code coverage report
	@jlcoverage

docs:
	cd docs; julia --compile=min -O0 make.jl

# Maintenance
clean:
	@echo Remove coverage files
	julia --color=yes --compile=min -O0 -e 'using Coverage; clean_folder(".");'

spotless: clean
	find . -name "Manifest.toml" -exec rm -rf {} \;  # Manifest.toml files

# Phony Targets
.PHONY: all \
		test \
		docs \
		clean spotless
