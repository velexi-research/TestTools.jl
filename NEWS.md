TestTools Release Notes
=======================

--------------------------------------------------------------------------------------------
v0.5.4 (2023-12-18)
-------------------
**Developer Updates:**
- Polished package documentation.
- Improved security and robustness of GitHub Action workflows.
- Updated Python package dependencies.

--------------------------------------------------------------------------------------------
v0.5.3 (2023-11-16)
-------------------
**Developer Updates:**
- Updated unit tests to be compatible with Julia 1.9.
- Updated CompatHelper GitHub Action workflows.
- Updated Julia and Python package dependencies.

--------------------------------------------------------------------------------------------
v0.5.2 (2023-03-30)
-------------------
**Developer Updates:**
- Migrated to use of GitHub Actions for deployment of documentation to GitHub Pages.
  This update was needed for compatibility with recent changes to GitHub Pages (when
  symbolic links are present in the site).

--------------------------------------------------------------------------------------------
v0.5.1 (2023-03-26)
-------------------
**Enhancements:**
- Improved performance of `jltest`.

--------------------------------------------------------------------------------------------
v0.5.0 (2022-11-25)
-------------------
**Enhancements:**
- Added options for verbose mode and code coverage for `jltest`.
- Simplified and improved robustness of CLI installer.

**Developer Updates:**
- Improved consistency of code style with Blue.

--------------------------------------------------------------------------------------------
v0.4.2 (2022-11-18)
-------------------
**Bug Fixes:**
- Fixed bug when get_test_statistics() is called with an argument that is not a
  DefaultTestSet, EnhancedTestSet{DefaultTestSet}, or nothing.

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
