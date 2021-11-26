#!/bin/bash
# -*- mode: julia -*-
#=
exec julia --color=yes --startup-file=no \
           --project=`dirname "${BASH_SOURCE[0]}"` "${BASH_SOURCE[0]}" "$@"
=#
"""
Initialize Julia package.

------------------------------------------------------------------------------
Copyright (c) 2020-2021 Velexi Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
------------------------------------------------------------------------------
"""
# --- Imports

using ArgParse
using DocumenterTools
using Logging
using Pkg
using PkgTemplates
using UUIDs

# --- Constants

STANDARD_PACKAGES = ["Documenter"]
EXAMPLE_MODULE_JL = "ExampleModule.jl"

# --- Main program

function main()

    # --- Preparations

    # Define command-line interface
    arg_table = ArgParseSettings()
    @add_arg_table! arg_table begin
        "--overwrite", "-f"
            help = "overwrite pre-existing package files"
            action = :store_true
        "--julia-version", "-j"
            help = "minimum Julia version"
            arg_type = VersionNumber
            default = v"1.6"
        "--dest-dir", "-d"
            help = "directory where Julia package will reside"
            default = "."
        "--license", "-l"
            help = "package license"
            default = "ASL"
        "pkg_name"
            help = "package name"
            required = true
    end

    # Parse command-line arguments
    args::Dict = parse_args(ARGS, arg_table)
    pkg_name::String = args["pkg_name"]
    overwrite::Bool = args["overwrite"]
    julia_version::VersionNumber = args["julia-version"]
    dst_dir::String = args["dest-dir"]
    license::String = args["license"]

    # Construct name of temporary directory
    tmp_dir = "tmp.init-pkg." * string(uuid4())

    # --- Initialize Julia package

    # Create package
    create_pkg(pkg_name, tmp_dir, julia_version, license)

    # Move package files to destination directory
    success = move_pkg(pkg_name, tmp_dir, dst_dir, overwrite=overwrite)

    # --- Set up standard package structure

    # Rename EXAMPLE_MODULE_JL to $pkg_name.jl
    if success
        success = initialize_pkg_module_file(pkg_name, overwrite=overwrite)
    end

    # Add package depdendencies and documentation structure
    if success
        # Activate environment for package
        Pkg.activate(".")

        # Add standard package dependencies
        add_standard_packages_dependencies()

        # Generate standard documentation structure
        initialize_docs(pkg_name, overwrite=overwrite)
    end

    # --- Clean up

    clean_up(tmp_dir)
end

# --- Helper Functions

"""
    create_pkg(pkg_name::String, tmp_dir::String,
               julia_version::VersionNumber, license::String)

Create Julia package.
"""
function create_pkg(pkg_name::String, tmp_dir::String,
                    julia_version::VersionNumber, license::String)

    @info "Creating '$pkg_name' package"

    pkg_template = Template(dir=tmp_dir,
                            julia=julia_version,
                            plugins=[License(name=license),
                                     !SrcDir, !Tests, !Readme,
                                     !Git, !CompatHelper, !TagBot])

    pkg_template(pkg_name)
end

"""
    move_pkg(pkg_name::String, tmp_dir::String, dst_dir::String,
             overwrite::Bool)

Move Julia package in `tmp_dir/pkg_name` to `dst_dir`. Return `true` if
successful; otherwise, return false.
"""
function move_pkg(pkg_name::String, tmp_dir::String, dst_dir::String;
                  overwrite::Bool=false)

    # Emit progress message
    message = string("Moving package to destination directory ",
                     dst_dir in (".", "..") ? "'$dst_dir'" : dst_dir)
    @info message

    # Preparations
    tmp_pkg_dir::String = joinpath(tmp_dir, pkg_name)
    pkg_contents::Vector = readdir(tmp_pkg_dir, sort=false)

    # Check for items that will be overwritten
    items_will_be_overwritten::Bool = false
    if !overwrite
        # Check package contents
        for item in pkg_contents
            dest_path = joinpath(dst_dir, item)
            if ispath(dest_path)
                items_will_be_overwritten = true

                # Emit error message
                message = string(
                    "$item already exists in destination directory ",
                    dst_dir in (".", "..") ? "'$dst_dir'" : dst_dir)
                @error message
            end
        end
    end

    # Move package contents
    if overwrite || !items_will_be_overwritten
        for item in pkg_contents
            mv(joinpath(tmp_pkg_dir, item), joinpath(dst_dir, item),
               force=overwrite)
        end
    end

    return overwrite || !items_will_be_overwritten
end

"""
    initialize_pkg_module_file(pkg_name::String; overwrite::Bool)

Rename EXAMPLE_MODULE_JL to `pkg_name`.jl. Return `true` if successful;
otherwise, return false.
"""
function initialize_pkg_module_file(pkg_name::String; overwrite::Bool=false)
    # --- Preparations

    pkg_module_path::String = joinpath(".", "src", "$pkg_name.jl")
    template_pkg_module_path::String = joinpath("src", EXAMPLE_MODULE_JL)

    # --- Check paths

    pkg_module_path_exists = ispath(pkg_module_path)
    if !overwrite && pkg_module_path_exists
        message = "$pkg_module_path already exists in `src` directory. " *
                  "Keeping original."
        @warn message
        return true
    end

    if !ispath(template_pkg_module_path)
        message = "$template_pkg_module_path not found in `src` directory. " *
                  "Attempting to restore from git repository."
        @info message

        # Restore EXAMPLE_MODULE_JL
        try
            run(`git checkout $template_pkg_module_path`)
        catch
            message = "Unable to restore $template_pkg_module_path"
            @error message

            return false
        end
    end

    # --- Rename module file

    mv(template_pkg_module_path, pkg_module_path, force=overwrite)

    return true
end

"""
    add_standard_packages_dependencies()

Add standard dependencies.
"""
function add_standard_packages_dependencies()
    @info "Adding standard package dependencies"
    for package in STANDARD_PACKAGES
        Pkg.add(package)
    end
end

"""
    initialize_docs(pkg_name::String; overwrite::Bool)

Generate standard documentation structure.
"""
function initialize_docs(pkg_name::String; overwrite::Bool=false)
    @info "Generating standard documentation structure"
    if isdir("docs")
        if overwrite
            rm("docs", force=true, recursive=true)
        else
            message = "`docs` directory already exists. Keeping original."
            @warn message
            return
        end
    end

    DocumenterTools.generate(name=pkg_name)
end

"""
    clean_up(tmp_dir::String)

Remove temporary directories.
"""
function clean_up(tmp_dir::String)
    @info "Cleaning up"
    rm(tmp_dir, force=true, recursive=true)
end

# --- Run main program

main()
