#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

var stones = input.split(separator: " ").map({ Int(String($0))! })
let blinks = 75

for b in 1...blinks {
    print(b, stones.count)
    var newStones: [Int] = []
    for s in 0..<stones.count {
        if stones[s] == 0 {
            newStones.append(1)
        }
        else {
            var x = stones[s]
            var exp = 0
            while x > 0 {
                x = x / 10
                exp += 1
            }

            if exp > 0 && exp.isMultiple(of: 2) {
                exp = Int(pow(10.0, Double(exp / 2)))
                newStones.append(stones[s] / exp)
                newStones.append(stones[s] % exp)
            }
            else {
                newStones.append(stones[s] * 2024)
            }
        }
    }
    stones = newStones
}
print("Total number of stones for \(blinks) blinks: \(stones.count)")
