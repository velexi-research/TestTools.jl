#   Copyright (c) 2022 Velexi Corporation
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

const default_julia_flags = ["--startup-file=no", "-q", "--compile=min", "-O0"]

"""
    TestTools.install(; <keyword arguments>)

Install all of the CLI utilities.

# Keyword arguments

* `julia::AbstractString`: path to julia executable. Default: path of the current running
    julia

* `bin_dir::AbstractString`: directory to install CLI utilities into.
    Default: `~/.julia/bin`

* `julia_flags::Vector{<:AbstractString}`: command line flags for CLI executables.
    Default: `["--startup-file=no", "-q", "--compile=min", "-O0"]`

* `force::Bool`: flag used to indicate that existing CLI executables should be
    overwritten. Default: `false`
"""
function install(;
    julia::AbstractString=joinpath(Sys.BINDIR, Base.julia_exename()),
    bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"),
    julia_flags::Vector{<:AbstractString}=default_julia_flags,
    force::Bool=false,
)
    # --- Install CLI utilities

    for cli in cli_tools
        install_cli(cli; julia=julia, bin_dir=bin_dir, julia_flags=julia_flags, force=force)
    end

    # --- Emit informational message

    @info """
          Make sure that `$(bin_dir)` is in PATH, or manually add a
          symlink from a directory in PATH to the installed program file.
          """
end

"""
    TestTools.install_cli(name::AbstractString; <keyword arguments>)

Install executable for CLI named `cli`.

Valid values for `name`: "jltest", "jlcoverage", "jlcodestyle".

# Keyword arguments

* `julia::AbstractString`: path to julia executable. Default: path of the current running
    julia

* `bin_dir::AbstractString`: directory to install CLI executable into.
    Default: `~/.julia/bin`

* `julia_flags::Vector{<:AbstractString}`: command line flags for CLI executable.
    Default: `["--startup-file=no", "-q", "--compile=min", "-O0"]`

* `force::Bool`: flag used to indicate that existing CLI executable should be
    overwritten. Default: `false`
"""
function install_cli(
    cli::AbstractString;
    julia::AbstractString=joinpath(Sys.BINDIR, Base.julia_exename()),
    bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"),
    julia_flags::Vector{<:AbstractString}=default_julia_flags,
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

    open(exec_path, "w") do io
        if os == :windows
            # TODO: Find a way to embed the script in the file
            print(
                io,
                """
:: -----------------------------------------------------------------------------------------
::  Copyright (c) 2022 Velexi Corporation
::
::  Licensed under the Apache License, Version 2.0 (the "License");
::  you may not use this file except in compliance with the License.
::  You may obtain a copy of the License at
::
::      http://www.apache.org/licenses/LICENSE-2.0
::
::  Unless required by applicable law or agreed to in writing, software
::  distributed under the License is distributed on an "AS IS" BASIS,
::  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
::  See the License for the specific language governing permissions and
::  limitations under the License.
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
exec $(julia) $(join(julia_flags, ' ')) "\${BASH_SOURCE[0]}" "\$@"
=#

#   Copyright (c) 2022 Velexi Corporation
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

""",
            )
            open(abspath(@__DIR__, cli, "cli", "main.jl"), "r") do main
                line_count = 1
                for line in eachline(main)
                    if line_count > 10
                        println(io, line)
                    end
                    line_count += 1
                end
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

* `bin_dir::AbstractString`: directory containing CLI executables to uninstall.
    Default: `~/.julia/bin`
"""
function uninstall(; bin_dir::AbstractString=joinpath(DEPOT_PATH[1], "bin"))
    for cli in cli_tools
        uninstall_cli(cli; bin_dir=bin_dir)
    end
end

"""
    TestTools.uninstall_cli(name::AbstractString; <keyword arguments>)

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
