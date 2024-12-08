#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Line: CustomStringConvertible {
    let result: Int
    let operands: [String]

    var description: String { 
        get {
            "\(result): \(operands)"
        }
    }
}

enum Operator {
    case add
    case mul
    case concat
}

func operators(for operands: [String], use: [Operator]) -> [[Operator]] {
    var result: [[Operator]] = []
    if operands.count > 2 {
        for ops in operators(for: [String](operands[1..<operands.count]), use: use) {
            for op in use {
                result.append([op] + ops);
            }
        }
    }
    else {
        result = use.map({ [$0] })
    }
    return result
}

let lines = input.split(separator: "\n").map({ line in 
    let parts = line.split(separator: ":")
    return Line(result: Int(parts.first!)!, 
                operands: parts.last!.split(separator: " ").map({ String($0) }))
})

var firstResult = 0
for line in lines {
    for ops in operators(for: line.operands, use: [.add, .mul]) {
        var result = Int(line.operands.first!)!
        for i in 0..<ops.count {
            switch ops[i] {
                case .add: result += Int(line.operands[i+1])!
                case .mul: result *= Int(line.operands[i+1])!
                default: break
            }
        }
        if result == line.result {
            firstResult += result
            break
        }
    }
}
print("Total Calibration Result: \(firstResult)")

var secondResult = 0
for line in lines {
    for ops in operators(for: line.operands, use: [.add, .mul, .concat]) {
        var result = Int(line.operands.first!)!
        for i in 0..<ops.count {
            switch ops[i] {
                case .add: result += Int(line.operands[i+1])!
                case .mul: result *= Int(line.operands[i+1])!
                case .concat: result = Int(String(result) + line.operands[i+1])!
            }
        }
        if result == line.result {
            secondResult += result
            break
        }
    }
}
print("Total Calibration Result: \(secondResult)")
