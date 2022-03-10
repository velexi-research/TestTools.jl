"""
main.jl contains the main program for the `jltest` CLI.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

using TestTools: TestTools, jltest

# --- Main program

# Parse CLI arguments
args = jltest.cli.parse_args()

# Handle --version option
if args["version"]
    println(
        "$(basename(PROGRAM_FILE)) $(TestTools.VERSION) " *
        "(from $(dirname(PROGRAM_FILE)))",
    )
    exit(0)
end

# Run main program
jltest.cli.run(args["tests"]; fail_fast=args["fail-fast"], verbose=args["verbose"])
