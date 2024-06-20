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
Unit tests for the package installer/uninstaller functions in `TestTools`.
"""

# --- Imports

# Standard library
using Test

# External packages
using Suppressor

# Local modules
using TestTools: TestTools
using TestTools.jltest: EnhancedTestSet

# --- Tests

@testset EnhancedTestSet "TestTools: install(), uninstall()" begin

    # --- Preparations

    # Construct path to test installation directory
    bin_dir = mktempdir()

    # Cache common variables
    jltest_cmd = "jltest"
    jlcoverage_cmd = "jlcoverage"
    jlcodestyle_cmd = "jlcodestyle"
    if Sys.iswindows()
        jltest_cmd = "$jltest_cmd.ps1"
        jlcoverage_cmd = "$jlcoverage_cmd.ps1"
        jlcodestyle_cmd = "$jlcodestyle_cmd.ps1"
    end

    # --- install() tests

    jltest_exec_path = abspath(bin_dir, jltest_cmd)
    jlcoverage_exec_path = abspath(bin_dir, jlcoverage_cmd)
    jlcodestyle_exec_path = abspath(bin_dir, jlcodestyle_cmd)

    # ------ Case: fresh installation

    output = @capture_err begin
        TestTools.install(; bin_dir=bin_dir)
    end

    expected_output = """
        [ Info: Installed $jltest_cmd to `$jltest_exec_path`.
        [ Info: Installed $jlcoverage_cmd to `$jlcoverage_exec_path`.
        [ Info: Installed $jlcodestyle_cmd to `$jlcodestyle_exec_path`.
        ┌ Info: Make sure that `$bin_dir` is in PATH, or manually add a
        └ symlink from a directory in PATH to the installed program file.
        """
    @test output == expected_output

    @test isfile(jltest_exec_path)
    @test isfile(jlcoverage_exec_path)
    @test isfile(jlcodestyle_exec_path)

    # ------ Case: attempt to reinstall with force=false

    output = @capture_err begin
        TestTools.install(; bin_dir=bin_dir)
    end

    expected_output = """
         ERROR: File `$(abspath(bin_dir, jltest_cmd))` already exists.
         ERROR: File `$(abspath(bin_dir, jlcoverage_cmd))` already exists.
         ERROR: File `$(abspath(bin_dir, jlcodestyle_cmd))` already exists.
         Use `TestTools.install(force=true)` to overwrite existing CLI executables.
         """
    @test output == expected_output

    @test isfile(jltest_exec_path)
    @test isfile(jlcoverage_exec_path)
    @test isfile(jlcodestyle_exec_path)

    # ------ Case: attempt to reinstall with force=true

    output = @capture_err begin
        TestTools.install(; bin_dir=bin_dir, force=true)
    end

    expected_output = """
        [ Info: Installed $jltest_cmd to `$jltest_exec_path`.
        [ Info: Installed $jlcoverage_cmd to `$jlcoverage_exec_path`.
        [ Info: Installed $jlcodestyle_cmd to `$jlcodestyle_exec_path`.
        ┌ Info: Make sure that `$bin_dir` is in PATH, or manually add a
        └ symlink from a directory in PATH to the installed program file.
        """
    @test output == expected_output

    @test isfile(jltest_exec_path)
    @test isfile(jlcoverage_exec_path)
    @test isfile(jlcodestyle_exec_path)

    # --- uninstall() tests

    # ------ Case: uninstall

    output = @capture_err begin
        TestTools.uninstall(; bin_dir=bin_dir)
    end

    expected_output = """
        [ Info: Uninstalled `$jltest_exec_path`.
        [ Info: Uninstalled `$jlcoverage_exec_path`.
        [ Info: Uninstalled `$jlcodestyle_exec_path`.
        """
    @test output == expected_output
    @test !isfile(jltest_exec_path)
    @test !isfile(jlcoverage_exec_path)
    @test !isfile(jlcodestyle_exec_path)
end

@testset EnhancedTestSet "TestTools: install_cli(), uninstall_cli(): invalid arguments" begin

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
