<!---
    Copyright (c) 2022 Velexi Corporation

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
-->

By default, `jlcodestyle` applies the Blue style, so running the following command will
detect style errors:

```julia
$ jlcodestyle default-style.jl
```

With the `-o` or `--overwrite` option, the original file will be overwritten with a file
that has the style errors corrected.
