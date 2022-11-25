#   Copyright 2022 Velexi Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
pkg.jl defines package management functions.
"""

# --- Constants

const cli_tools = ["jltest", "jlcoverage", "jlcodestyle"]

# --- CLI installer functions

"""
    TestTools.install(; kwargs...)

Install all of the CLI utilities.

# Keyword arguments

* `julia::AbstractString`: path to julia executable. Default: path of the current running
    julia

* `bin_dir::AbstractString`: directory to install CLI utilities into.
    Default: `~/.julia/bin`

* `force::Bool`: flag used to indicate that existing CLI executables should be
    overwritten. Default: `false`
"""
function install(;
    julia::AbstractString=joinpath(Sys.BINDIR, Base.julia_exename()),
    bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"),
    force::Bool=false,
)
    # --- Install CLI utilities

    for cli in cli_tools
        install_cli(cli; julia=julia, bin_dir=bin_dir, force=force)
    end

    # --- Emit informational message

    @info """
          Make sure that `$(bin_dir)` is in PATH, or manually add a
          symlink from a directory in PATH to the installed program file.
          """
end

"""
    TestTools.install_cli(name::AbstractString; kwargs...)

Install executable for CLI named `cli`.

Valid values for `name`: "jltest", "jlcoverage", "jlcodestyle".

# Keyword arguments

* `julia::AbstractString`: path to julia executable. Default: path of the current running
    julia

* `bin_dir::AbstractString`: directory to install CLI executable into.
    Default: `~/.julia/bin`

* `force::Bool`: flag used to indicate that existing CLI executable should be
    overwritten. Default: `false`
"""
function install_cli(
    cli::AbstractString;
    julia::AbstractString=joinpath(Sys.BINDIR, Base.julia_exename()),
    bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"),
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
    bin_dir = abspath(expanduser(bin_dir))

    # Get absolute path to executable to be installed
    exec_path = joinpath(bin_dir, cli)

    # Check if the executable already exists
    if ispath(exec_path) && !force
        error(
            "File `$(Base.contractuser(exec_path))` already exists. " *
            "Use `TestTools.install(force=true)` to overwrite.",
        )
    end

    # Create installation directory
    mkpath(bin_dir)

    # --- Install executable

    open(exec_path, "w") do installed_cli
        if os == :windows
            # TODO: test and debug on Windows

            # Generate PowerShell part of CLI script
            open(abspath(dirname(@__DIR__), "bin", cli), "r") do bin_cli
                for line in eachline(bin_cli)
                    # Skip shebang interpreter directive
                    if occursin("#!/usr/bin/env bash", line)
                        continue
                    end

                    # Stop processing lines when Julia section starts
                    if occursin("mode: julia", line)
                        println(installed_cli, line)
                        break
                    end

                    # If line contains `exec julia`, replace julia executable
                    if occursin("exec julia", line)
                        line = replace(line, "exec julia" => "exec $(julia)")
                    end

                    # Copy line to installed CLI
                    println(installed_cli, line)
                end
            end

        else # unix
            # Generate bash part of CLI script
            open(abspath(dirname(@__DIR__), "bin", cli), "r") do bin_cli
                for line in eachline(bin_cli)
                    # Stop processing lines when Julia section starts
                    if occursin("mode: julia", line)
                        println(installed_cli, line)
                        break
                    end

                    # If line contains `exec julia`, replace julia executable
                    if occursin("exec julia", line)
                        line = replace(line, "exec julia" => "exec $(julia)")
                    end

                    # Copy line to installed CLI
                    println(installed_cli, line)
                end
            end
        end

        # Generate Julia part of CLI script
        open(abspath(@__DIR__, cli, "cli", "main.jl"), "r") do main
            line_count = 0
            for line in eachline(main)
                # Skip copyright incantation
                if line_count < 14
                    line_count += 1
                    continue
                end

                # Copy line to installed CLI
                println(installed_cli, line)
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
    TestTools.uninstall(; kwargs...)

Unnstall all of the CLI utilities.

# Keyword arguments

* `bin_dir::AbstractString`: directory containing CLI executables to uninstall.
    Default: `~/.julia/bin`
"""
function uninstall(; bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"))
    for cli in cli_tools
        uninstall_cli(cli; bin_dir=bin_dir)
    end
end

"""
    TestTools.uninstall_cli(name::AbstractString; kwargs...)

Uninstall executable for CLI named `cli`.

Valid values for `name`: "jltest", "jlcoverage", "jlcodestyle".

# Keyword arguments

* `bin_dir::AbstractString`: directory containing CLI executable to uninstall.
    Default: `~/.julia/bin`
"""
function uninstall_cli(
    cli::AbstractString; bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin")
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
    bin_dir = abspath(expanduser(bin_dir))

    # Get absolute path to executable to be installed
    exec_path = joinpath(bin_dir, cli)

    # --- Uninstall CLI

    rm(exec_path; force=true)

    # --- Emit informational message

    @info "Uninstalled `$(Base.contractuser(exec_path))`."

    return nothing
end
