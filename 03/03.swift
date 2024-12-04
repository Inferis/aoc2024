#!/usr/bin/swift -enable-bare-slash-regex

import Foundation
import _StringProcessing

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let mulExpression = /mul\(([0-9]+),([0-9]+)\)/
let allTotal = input.matches(of: mulExpression).map({ Int($0.1)! * Int($0.2)! }).reduce(0, +)
print("Total of all muls: \(allTotal)")

let conditionalMulExpression = /do\(\)|don't\(\)|mul\(([0-9]+),([0-9]+)\)/
var enabled = true
var conditionalTotal = 0
for match in input.matches(of: conditionalMulExpression) {
    if match.0 == "do()" {
        enabled = true
    } 
    else if match.0 == "don't()" {
        enabled = false
    }
    else if enabled {
        conditionalTotal = conditionalTotal + (Int(match.1!)! * Int(match.2!)!)
    }
}
print("Total of conditional muls: \(conditionalTotal)")
