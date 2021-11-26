"""
TODO
"""
# --- Exports

export analyze_coverage, display_coverage

# --- Imports

# Standard library
using Logging
using Printf

# External packages
using ArgParse
using Coverage

# --- Public functions/methods

"""
    analyze_coverage(src_dir::String, tmp_dir::String)

Analyze test coverage.

Arguments
---------
* TODO

Return value
------------
* TODO

"""
function analyze_coverage(src_dir::String, test_dir::String)
    # Process '*.cov' files
    coverage = process_folder(src_dir)

    # Process '*.info' files
    coverage = merge_coverage_counts(
        coverage,
        filter!(
            let prefixes = (src_dir, "")
                c -> any(p -> startswith(c.filename, p), prefixes)
            end,
            LCOV.readfolder(test_dir),
        ),
    )

    return coverage
end

"""
    display_results(coverage::Array)

Display coverage results.

Arguments
---------
* TODO

Return value
------------
* TODO

"""
function display_results(coverage::Array)

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
    for file_coverage in coverage
        filename = file_coverage.filename
        filename = filename[(findlast("src/", filename)[1] + 4):end]

        covered_lines_of_code, lines_of_code = get_summary(
            process_file(file_coverage.filename)
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

# --- Private functions

"""
    printf(fmt, args...)

Print formatted text.

Arguments
---------
* TODO

Return value
------------
* TODO

"""
printf(fmt, args...) = @eval @printf($fmt, $(args...))
