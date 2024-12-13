#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

var stones = input.split(separator: " ").map({ Int(String($0))! })

func blink(stones: [Int], concurrent: Bool) -> [Int] {
    if concurrent {
        var newStones: [Int] = []
        let group = DispatchGroup()
        let lock = NSLock()
        for s in stones {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                if s == 0 {
                    lock.lock()
                    newStones.append(1)
                    lock.unlock()
                }
                else {
                    var digits = Int(floor(log10(Double(s))))+1
                    if digits.isMultiple(of: 2) {
                        digits = Int(pow(10.0, Double(digits / 2)))
                        let left = s / digits
                        let right = s % digits
                        lock.lock()
                        newStones.append(left)
                        newStones.append(right)
                        lock.unlock()
                    }
                    else {
                        lock.lock()
                        newStones.append(s * 2024)
                        lock.unlock()
                    }
                }
                group.leave()
            }
        }
        group.wait()
        return newStones
    }
    else {
        return stones.flatMap({ s in 
            if s == 0 {
                return [1]
            }
            else {
                var digits = Int(floor(log10(Double(s))))+1
                if digits.isMultiple(of: 2) {
                    digits = Int(pow(10.0, Double(digits / 2)))
                    let left = s / digits
                    let right = s % digits
                    return [left, right]
                }
                else {
                    return [s * 2024]
                }
            }
        })
    }
}

for b in 1...25 {
    print(b, stones.count)
    stones = blink(stones: stones, concurrent: true)
}
print("Total number of stones for 25 blinks: \(stones.count)")

for b in 1...50 {
    print(25+b, stones.count)
    stones = blink(stones: stones, concurrent: true)
}
print("Total number of stones for 75 blinks: \(stones.count)")
