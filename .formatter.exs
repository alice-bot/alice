locals_without_parens = [
  #Alice.Router
  command: 2,
  route: 2
]


[
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  inputs: ["*.{ex,exs}", "{config,lib,priv,test}/**/*.{ex,exs}"]
]
