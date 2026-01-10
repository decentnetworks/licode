# Ubuntu 24.04.1 changes

This document tracks changes made to build Licode on Ubuntu 24.04.1.

## 2025-02-15
- Updated Abseil dependency to avoid build failures with GCC 13 and newer libstdc++ headers.
  - File: erizo/conanfile.txt
  - Change: abseil/20211102.0 -> abseil/20230125.3
  - Rationale: Abseil 20211102.0 is missing <cstdint> includes in
    absl/strings/internal/str_format/extension.h, which causes build errors.
