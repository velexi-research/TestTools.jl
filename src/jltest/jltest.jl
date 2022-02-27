"""
The jltest module provides support for running unit tests.

Acknowledgements
----------------
* Much of the core functionality of the `TestSetPlus` type (and associated methods) were
  taken directly from the TestSetExtensions package developed by Spencer Russell and
  his collaborators (https://github.com/ssfrr/TestSetExtensions.jl). `TestSetPlus` builds
  upon the foundation of `ExtendedTestSet`

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
module jltest

# Public API
include("TestSetPlus.jl")
include("utils.jl")

# CLI
include("cli.jl")

end  # End of jltest module
