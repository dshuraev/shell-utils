# Shell Utils

This is collection of various scripts and shell components.

The intention is to keep all components as portable and dependency-free as possible.

## Structure

Files are marked depending on their purpose and language used.
For instance, `file.lib.bash` is intended to be used as a library for other
bash scripts.

## Style Guide

1. Document scripts as per man page conventions. For complex cases, use doxygen.
2. Use shell-check, if applicable.
3. Namespaces:
    - for bash files use `<filename>_` prefix for all globally scoped
    variables and functions.
4. Prefer using built-ins (or common) utilities to non-standard ones.

    A complicated `sed` solution is better than a simple `jq` solution,
    `bash` > `python`, etc.
5. Shared components should have `.lib.<lang>` extension; scripts `.<lang>`.
    - `.sh` for shell
    - `.bash` for bash
    - `.fish` for fish
6. Use conventional commits.
