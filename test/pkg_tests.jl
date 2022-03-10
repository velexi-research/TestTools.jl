"""
Unit tests for the package installer/uninstaller functions in `TestTools`.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

# Standard library
using Test

# External packages
using Suppressor

# Local modules
using TestTools: TestTools
using TestTools.jltest: TestSetPlus

# --- Tests

@testset TestSetPlus "TestTools: install(), uninstall()" begin

    # --- Preparations

    # Construct path to test installation directory
    install_dir = abspath(joinpath(@__DIR__, "testing-dir"))

    # Cache common variables
    jltest_exec_path = Base.contractuser(joinpath(install_dir, "jltest"))
    jlcoverage_exec_path = Base.contractuser(joinpath(install_dir, "jlcoverage"))
    jlcodestyle_exec_path = Base.contractuser(joinpath(install_dir, "jlcodestyle"))

    expected_output_install = """
        [ Info: Installed jltest to `$(jltest_exec_path)`.
        [ Info: Installed jlcoverage to `$(jlcoverage_exec_path)`.
        [ Info: Installed jlcodestyle to `$(jlcodestyle_exec_path)`.
        ┌ Info: Make sure that `$(install_dir)` is in PATH, or manually add a
        └ symlink from a directory in PATH to the installed program file.
        """

    expected_output_uninstall = """
        [ Info: Uninstalled `$(jltest_exec_path)`.
        [ Info: Uninstalled `$(jlcoverage_exec_path)`.
        [ Info: Uninstalled `$(jlcodestyle_exec_path)`.
        """

    # --- install() tests

    # Remove existing install directory
    if isdir(install_dir)
        rm(install_dir; force=true, recursive=true)
    end

    # Case: fresh installation
    output = @capture_err begin
        TestTools.install(; install_dir=install_dir)
    end

    @test output == expected_output_install

    # Case: attempt to reinstall with force=false
    local error
    try
        TestTools.install(; install_dir=install_dir)
    catch error
    end

    expected_error =
        "File `$(jltest_exec_path)` already exists. " *
        "Use `TestTools.install(force=true)` to overwrite."
    @test error.msg == expected_error

    # Case: attempt to reinstall with force=true
    output = @capture_err begin
        TestTools.install(; install_dir=install_dir, force=true)
    end

    @test output == expected_output_install

    # --- uninstall() tests

    # Case: uninstall
    output = @capture_err begin
        TestTools.uninstall(; install_dir=install_dir)
    end

    @test output == expected_output_uninstall

    # --- Clean up

    rm(install_dir)
end

@testset TestSetPlus "TestTools: install_cli(), uninstall_cli(): invalid arguments" begin

    # --- install_cli() tests

    # Case: invalid `cli` arg
    local error
    try
        TestTools.install_cli("invalid-cli")
    catch error
    end

    expected_error = "Invalid `cli`: invalid-cli"
    @test error.msg == expected_error

    # --- uninstall_cli() tests

    # Case: invalid `cli` arg
    local error
    try
        TestTools.uninstall_cli("invalid-cli")
    catch error
    end

    expected_error = "Invalid `cli`: invalid-cli"
    @test error.msg == expected_error
end
