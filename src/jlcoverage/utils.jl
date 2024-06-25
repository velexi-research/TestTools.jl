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
jlcoverage/utils.jl defines utility functions to support code coverage analysis.
"""

# --- Exports

export display_coverage

# --- Imports

# Standard library
using Logging
using Printf

# External packages
using Coverage: Coverage

# --- Public Functions/Methods

"""
    display_coverage(coverage_data::Vector; startpath::AbstractString)

Display coverage results provided in `coverage_data`. File names are displayed relative
to `startpath`. To display absolute paths, set `startpath` to an empty string. By default,
`startpath` is set to the current working directory.
"""
function display_coverage(coverage_data::Vector; startpath::AbstractString=pwd())
    # --- Check arguments

    # Ensure that `startpath` is an absolute path
    if !isempty(startpath)
        startpath = realpath(abspath(startpath))
    end

    # --- Generate coverage report

    # Line formats
    header_line_format = "%-44s%15s%10s%10s\n"
    results_line_format = "%-44s%15d%10d%10s\n"
    horizontal_rule = "-"^80

    # Print header line
    println(horizontal_rule)
    printf(header_line_format, "File", "Lines of Code", "Missed", "Coverage")
    println(horizontal_rule)

    # Initialize line counters
    total_lines_of_code = 0
    total_covered_lines_of_code = 0

    # Print coverage for individual files
    for file_coverage in coverage_data
        if !isempty(startpath)
            filename = relpath(realpath(file_coverage.filename), startpath)
        else
            filename = file_coverage.filename
        end

        covered_lines_of_code, lines_of_code = Coverage.get_summary(file_coverage)
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
