"""
The TestTools package provides support for testing and code quality CLIs.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
module TestTools

# --- Package Metadata

using TOML: TOML
const VERSION = TOML.parsefile(joinpath(pkgdir(@__MODULE__), "Project.toml"))["version"]

# --- Submodules

# jlcodestyle
include("jlcodestyle/jlcodestyle.jl")

# jlcoverage
include("jlcoverage/jlcoverage.jl")

# jltest
include("jltest/jltest.jl")

# --- Constants
#
const cli_tools = ["jltest", "jlcoverage", "jlcodestyle"]

# --- CLI installer functions

const default_julia_flags = ["--startup-file=no", "-q", "--compile=min", "-O0"]

"""
    TestTools.install(; <keyword arguments>)

Install all of the CLI utilities.

# Keyword arguments

* `julia`: path to julia executable, defaults to the path of the current running julia.

* `install_dir`: writable directory (available in PATH) for the executable.
  Default: `~/.julia/bin`.

* `julia_flags`: vector with command line flags for the julia executable,
   defaults to `["--startup-file=no", "-q", "--compile=min", "-O0"]`.

* `force`: boolean used to overwrite any existing commands.
"""
function install(;
    julia::String=joinpath(Sys.BINDIR, Base.julia_exename()),
    install_dir::String=joinpath(DEPOT_PATH[1], "bin"),
    julia_flags::Vector{String}=default_julia_flags,
    force::Bool=false,
)
    # --- Install CLI utilities

    for cli in cli_tools
        install_cli(
            cli; julia=julia, install_dir=install_dir, julia_flags=julia_flags, force=force
        )
    end

    # --- Emit informational message

    @info """
          Make sure that `$(install_dir)` is in PATH, or manually add a
          symlink from a directory in PATH to the installed program file.
          """
end

"""
    TestTools.install_cli(name::AbstractString; <keyword arguments>)

Install executable for CLI named `cli`.

Valid values for `name`: "jltest", "jlcoverage", "jlcodestyle".

# Keyword arguments

* `julia`: path to julia executable, defaults to the path of the current running julia.

* `install_dir`: writable directory (available in PATH) for the executable.
  Default: `~/.julia/bin`.

* `julia_flags`: vector with command line flags for the julia executable,
   defaults to `["--startup-file=no", "-q", "--compile=min", "-O0"]`.

* `force`: boolean used to overwrite any existing executables.
"""
function install_cli(
    cli::AbstractString;
    julia::String=joinpath(Sys.BINDIR, Base.julia_exename()),
    install_dir::String=joinpath(DEPOT_PATH[1], "bin"),
    julia_flags::Vector{String}=default_julia_flags,
    force::Bool=false,
)
    # --- Check arguments

    if !(cli in cli_tools)
        throw(ArgumentError("Invalid `cli`: $(cli)"))
    end

    # --- Preparations

    # Get OS
    os = Sys.iswindows() ? :windows : :unix

    # Set name of CLI
    if os == :windows
        cli *= ".cmd"
    end

    # Get absolute path to installation directory
    install_dir = abspath(expanduser(install_dir))

    # Get absolute path to executable to be installed
    exec_path = joinpath(install_dir, cli)

    # Check if the executable already exists
    if ispath(exec_path) && !force
        error(
            "File `$(exec_path)` already exists. " *
            "Use `TestTools.install(force=true)` to overwrite.",
        )
    end

    # Create installation directory
    mkpath(install_dir)

    # --- Install executable

    open(exec_path, "w") do io
        if os == :windows
            # TODO: Find a way to embed the script in the file
            print(
                io,
                """
:: -----------------------------------------------------------------------------------------
:: COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
:: license terms in the LICENSE file found in the root directory of this distribution. No
:: part of the TestTools.jl package, including this file, may be copied, modified, propagated,
:: or distributed except according to the terms contained in the LICENSE file.
:: -----------------------------------------------------------------------------------------
@ECHO OFF
$(julia) $(join(julia_flags, ' ')) $(abspath(@__DIR__, cli, "cli", "main.jl")) %*
""",
            )

        else # unix
            print(
                io,
                """
#!/usr/bin/env bash
#=
exec_path $(julia) $(join(julia_flags, ' ')) "\${BASH_SOURCE[0]}" "\$@"
=#
\"\"\"
-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
\"\"\"
""",
            )
            open(abspath(@__DIR__, cli, "cli", "main.jl"), "r") do main
                write(io, main)
            end
        end
    end

    # Set permissions on executable
    chmod(exec_path, 0o0100755) # equivalent to -rwxrwxr-x (chmod +x exec_path)

    # --- Emit informational message

    @info "Installed $(cli) to `$(Base.contractuser(exec_path))`."

    return nothing
end

# --- CLI uninstaller functions

"""
    TestTools.uninstall(; <keyword arguments>)

Unnstall all of the CLI utilities.

# Keyword arguments

* `install_dir`: writable directory (available in PATH) for the executable.
  Default: `~/.julia/bin`.
"""
function uninstall(; install_dir::String=joinpath(DEPOT_PATH[1], "bin"))
    for cli in cli_tools
        uninstall_cli(cli; install_dir=install_dir)
    end
end

"""
    TestTools.uninstall_cli(name::AbstractString; <keyword arguments>)

Uninstall executable for CLI named `cli`.

Valid values for `name`: "jltest", "jlcoverage", "jlcodestyle".

# Keyword arguments

* `install_dir`: writable directory (available in PATH) for the executable.
  Default: `~/.julia/bin`.
"""
function uninstall_cli(
    cli::AbstractString; install_dir::String=joinpath(DEPOT_PATH[1], "bin")
)
    # --- Check arguments

    if !(cli in cli_tools)
        throw(ArgumentError("Invalid `cli`: $(cli)"))
    end

    # --- Preparations

    # Get OS
    os = Sys.iswindows() ? :windows : :unix

    # Set name of CLI
    if os == :windows
        cli *= ".cmd"
    end

    # Get absolute path to installation directory
    install_dir = abspath(expanduser(install_dir))

    # Get absolute path to executable to be installed
    exec_path = joinpath(install_dir, cli)

    # --- Uninstall CLI

    rm(exec_path; force=true)

    return nothing
end

end  # End of TestTools module
