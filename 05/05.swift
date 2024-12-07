#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let sections = input.split(separator: "\n\n")
let ordering = sections.first!.split(separator: "\n").map({ $0.split(separator: "|").map({ Int($0)! }) })
let updates = sections.last!.split(separator: "\n").map({ $0.split(separator: ",").map({ Int($0)! }) })

var correctMiddles = 0
var wrongUpdates: [[Int]] = []

for update in updates {
    var success = true
    for v in 0..<update.count {
        let orders = ordering.filter({ $0.first! == update[v] })
        for vo in v+1..<update.count {
            if orders.filter({ $0.last! == update[vo] }).count == 0 {
                success = false
                break
            }            
        }
        if !success {
            break
        }
    }

    if success {
        correctMiddles += update[update.count / 2]
    }
    else {
        wrongUpdates.append(update)
    }
}
print("Sum of middle values of correct updates: \(correctMiddles)")

var adjustedMiddles = 0
for var update in wrongUpdates {
    var swapped: Bool
    repeat {
        swapped = false
        for v in 0..<update.count-1 {
            if !ordering.contains([update[v], update[v+1]]) {
                // swap
                (update[v+1], update[v]) = (update[v], update[v+1])
                swapped = true
            }
        }
    }
    while swapped
    adjustedMiddles += update[update.count / 2]
}
print("Sum of middle values of adjusted updates: \(adjustedMiddles)")
