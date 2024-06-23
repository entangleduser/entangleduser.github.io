#!/usr/bin/env swift-shell
import Shell // @git/acrlc/shell

let inputs = CommandLine.arguments[1...]
var arguments = [
 "run", "carton", "dev", "--custom-index-page", "index.html"
]

if inputs.notEmpty {
 arguments.append(contentsOf: inputs)
}

try execv(.swift, arguments)
