TestTools.jl Release Notes
==========================

--------------------------------------------------------------------------------------------
v0.4.1 (2022-11-15)
-------------------
**Enhancements:**
- Improved robustness of testing module.

**Bug Fixes:**
- Fixed bug when using `include()` in test files.

--------------------------------------------------------------------------------------------
v0.4.0 (2022-11-14)
-------------------

**Enhancements:**
- Improved robustness of testing module isolation.
- Added test statistic collection to `jltest.run_tests()`
- Improved formatting of coverage report.
- Added pass/fail return values for `jltest.cli.run()` and `jlcodestyle.cli.run()`
- Add exit codes for CLI tools.
- Added support for Julia v1.8.

**Developer Updates:**
- Improved Makefile (e.g., added "help" target)
- Added pre-commit hooks.
- Updated unit tests to pass for Julia v1.8.
- Improve robustness of unit tests to source code modifications.
- Reformatted NEWS.md to use same format as TagBot for release notes.

--------------------------------------------------------------------------------------------
v0.3.4 (2022-04-29)
-------------------

**Bug Fixes:**
- Added missing NEWS.md entries.

--------------------------------------------------------------------------------------------
v0.3.3 (2022-04-28)
-------------------

**Bug Fixes:**
- Fixed license type detected by GitHub.
- Fixed copyright notices.
- Moved third-party software license notices to NOTICE file.

--------------------------------------------------------------------------------------------
v0.3.2 (2022-04-06)
-------------------

**Enhancements:**
- Simplified error message when the test environment has missing dependencies.

--------------------------------------------------------------------------------------------
v0.3.1 (2022-04-05)
-------------------

**Enhancements:**
- Improved error messages (e.g., when the test environment has missing dependencies).
- Switched to using relative paths when displaying testing status.
- Polished package documentation.

**Developer Updates:**
- Added GPG configuration for GitHub Actions.
- Fixed bugs in Makefile.

--------------------------------------------------------------------------------------------
v0.3.0 (2022-03-26)
-------------------

**Enhancements:**
- Added support for using `JLTEST_FAIL_FAST` environment variable to enable fail-fast when
  `Pkg.test()` is used to run tests.
- Updated package documentation.

--------------------------------------------------------------------------------------------
v0.2.2 (2022-03-24)
-------------------

**Bug Fixes:**
- Fixed auto-generation of documentation for tagged versions.

--------------------------------------------------------------------------------------------
v0.2.1 (2022-03-24)
-------------------

**Enhancements:**
- Added documentation for tagged versions.

--------------------------------------------------------------------------------------------
v0.2.0 (2022-03-24)
-------------------

**Enhancements:**
- Improved options for jltest API and CLI tool.
- Improved consistency of test results across mechanisms for running tests.
- Improved package documentation.

--------------------------------------------------------------------------------------------
v0.1.0 (2022-03-21)
-------------------
- Initial release of TestTools.jl package.

--------------------------------------------------------------------------------------------
