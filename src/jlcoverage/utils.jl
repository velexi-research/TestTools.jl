"""
jlcoverage/utils.jl defines utility functions to support code coverage analysis.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Exports

export analyze_coverage, display_coverage

# --- Imports

# Standard library
using Logging
using Printf

# External packages
using Coverage: Coverage

# --- Public Functions/Methods

"""
    analyze_coverage(src_dir::AbstractString, test_dir::AbstractString)

Analyze coverage of code in `src_dir` by tests in `test_dir`.
"""
function analyze_coverage(src_dir::AbstractString, test_dir::AbstractString)

    # Process '*.cov' files
    coverage = Coverage.process_folder(src_dir)

    # Process '*.info' files
    coverage = Coverage.merge_coverage_counts(
        coverage,
        filter!(
            let prefixes = (src_dir, "")
                c -> any(p -> startswith(c.filename, p), prefixes)
            end,
            Coverage.LCOV.readfolder(test_dir),
        ),
    )

    return coverage
end

"""
    display_results(coverage_data::Vector)

Display coverage results provided in `coverage_data`.
"""
function display_results(coverage_data::Vector)

    # Line formats
    header_line_format = "%-35s %15s %10s %10s\n"
    results_line_format = "%-35s %15d %10d %10s\n"
    horizontal_rule = "-"^79

    # Print header line
    println(horizontal_rule)
    printf(header_line_format, "File", "Lines of Code", "Missed", "Coverage")
    println(horizontal_rule)

    # Initialize line counters
    total_lines_of_code = 0
    total_covered_lines_of_code = 0

    # Print coverage for individual files
    for file_coverage in coverage_data
        filename = file_coverage.filename
        filename = filename[(findlast("src/", filename)[1] + 4):end]

        covered_lines_of_code, lines_of_code = Coverage.get_summary(
            Coverage.process_file(file_coverage.filename)
        )
        missed_lines_of_code = lines_of_code - covered_lines_of_code
        coverage_pct = 100 * covered_lines_of_code / lines_of_code
        coverage_pct_str = isnan(coverage_pct) ? "N/A" : @sprintf "%9.1f%%" coverage_pct

        printf(
            results_line_format,
            filename,
            lines_of_code,
            missed_lines_of_code,
            coverage_pct_str,
        )

        # Increment line counteres
        total_lines_of_code += lines_of_code
        total_covered_lines_of_code += covered_lines_of_code
    end

    # Print coverage summary
    total_missed_lines_of_code = total_lines_of_code - total_covered_lines_of_code
    coverage_pct = 100 * total_covered_lines_of_code / total_lines_of_code
    coverage_pct_str = isnan(coverage_pct) ? "N/A" : @sprintf "%9.1f%%" coverage_pct

    println(horizontal_rule)
    printf(
        results_line_format,
        "TOTAL",
        total_lines_of_code,
        total_missed_lines_of_code,
        coverage_pct_str,
    )

    # TODO: add count of tests passed, skipped, failed.
    # TODO: add test runtime

    return nothing
end

# --- Private Methods

"""
    printf(fmt, args...)

Print formatted text using format defined by `fmt` and values provided in `args`.
"""
printf(fmt, args...) = @eval @printf($fmt, $(args...))
