#!/usr/bin/env bash

## % docgen.lib.bash (3) | Version 1.1
## % Daniil Shuraev
## % 2024-05-28

## # SYNOPSIS
## ```bash
## . docgen.lib.bash
## docgen::help
## docgen::help_raw
## ```
## or `docgen.lib.bash --help [--raw]` to view documentation.

## # DESCRIPTION
## These functions will generate documentation based on source code comments.
## `docgen::help_raw` will go through the current script and parse all lines
## starting with doc-mark `## ` (note the space) as documentation comments.
## These lines will be printed to stdout with the doc-mark stripped.
##
## The comments will appear in the order they appear in the source code.
##
## `docgen::help` will do the same, but will convert documentation with `pandoc`
## and display it with `man` and `cat`. If either one is not present on the system,
## `docgen::help_raw` will be displayed instead.
##
## `docgen.lib.bash` can be also executed as a script to view this documentation.
## Use `docgen.lib.bash --help [--raw]` to view the docs. Will exit with 1 if
## invoked with wrong flags.

## ## Markdown Syntax
## Documentation syntax generally follows Pandoc extension of markdown specs.
## See [Pandoc User Manual](https://pandoc.org/MANUAL.html#pandocs-markdown) for details.
## You can also view the source of the library to get the general idea.
## \
## Notably, `black_before_header` extension is disabled, so no newline is required
## before a heading.
## It is also recommended to use ATX-style headings, e.g. `# L1 Heading`, as
## Setext-style headings may cause parsing issues.
## \
## Use Pandoc metadata blocks to include relevant information, i.e. NAME, VERSION,
## AUTHOR and DATE, as per man page specs:
## ```bash
## ## % docgen.lib.bash (3) | Version 1.0
## ## % Daniil Shuraev
## ## % 2024-05-07
## ```

## ## Generating Documentation
## In order to generate documentation for the script use
## ```bash
## docgen::help_raw | pandoc -f markdown-blank_before_header -s -t <format>
## ```
## For the list of supported formats, see
## [Pandoc documentation](https://pandoc.org/MANUAL.html#general-options).

## # CONFIGURATION
## Doc-mark can be configured as needed by setting `DOCGEN_MARK`
## environmental variable. The default is '##'.
## \
## The variable must be overridden *after* the script is sourced.
## Note that the *patterns containing ',' must be avoided*.

# doc-mark; should not contain ',' due to regex syntax.
declare DOCGEN_MARK="##"

## # INTERNAL FUNCTIONS
## `docgen::help_raw`
## :  Display documentation in raw format, i.e., stripping the comment docgen
##    comment marker as well as any of the following spaces.
##    This is primarily useful for piping into other programs, like pandoc.
##    See `docgen::help` function for reference usage.
##
docgen::help_raw() {
  command cat "$0" |                             # use `command` in case of user overrides
    sed -n "\,^[[:space:]]*${DOCGEN_MARK}.*,p" | # detect marked lines
    sed 's/^[[:space:]]*//' |                    # strip leading blanks
    cut -c $((${#DOCGEN_MARK} + 1))- |           # get only part after doc-mark
    sed 's/^[[:space:]]*//'                      # strip leading blanks
}

## `docgen::help`
## :  Display documentation in a nice format as long as `pandoc`, `man` and `cat`
##    are available on the system.
##    `pandoc` is used to convert pandoc-markdown into a man page,
##    `man` is used for formatting, and
##    `cat` is used as a pager, to avoid hang-ups.
##
docgen::help() {
  if [[ -n $(command -v pandoc) && -n $(command -v man) && -n $(command -v cat) ]]; then
    docgen::help_raw | pandoc -f markdown-blank_before_header -s -t man | man -l -P cat -
  else
    echo 'Help message is displayed in raw format.'
    echo 'Install pandoc and man to get better formatting'
    echo
    docgen::help_raw
  fi
}

main() {
  ## # OPTIONS
  while (($# > 0)); do
    case "$1" in
      -h | --help)
        ## `-h | --help [--raw]`
        ## :  Display this message. Use `--help --raw` to display in raw format.
        if [ "$2" = "--raw" ]; then
          docgen::help_raw
        else
          docgen::help
        fi
        exit
        ;;
      *)
        echo 'Use docgen.lib.bash --help [--raw]' for documentation.
        exit 1
        ;;
    esac
  done
}

# Do not eval if this file is sourced - only for self-documenting.
[[ "${0}" == "${BASH_SOURCE[0]}" ]] && main "$@"
