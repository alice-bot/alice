# Used by "mix format"
#
# Importing alice here will allow you to use Alice's built-in formatting rules.
# These include rules excluding parenthesis for the `command` and `router`
# functions
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:alice]
]
