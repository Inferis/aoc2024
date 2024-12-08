#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, Hashable, Comparable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        get {
            "(\(x), \(y))"
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func ==(a: Position, b: Position) -> Bool {
    return a.x == b.x && a.y == b.y
}

func <(a: Position, b: Position) -> Bool {
    return a.x < b.x || (a.x == b.x && a.y < b.y)
}

func print(map: [[String]]) {
    print(map.map({ $0.joined(separator: "") }).joined(separator: "\n"))
}

var map = input.split(separator: "\n").map({ $0.split(separator: "" ).map({ String($0) }) })
var width = map[0].count
var height = map.count
var signals: [String:[Position]] = [:]
for y in 0..<height {
    for x in 0..<width {
        let s = map[y][x]
        if s == "." { continue }
        let position = Position(x: x, y: y)
        if signals[s] == nil {
            signals[s] = [position]
        }
        else {
            signals[s]?.append(position)
        }
    }
}


func findAntinodes(_ signals: [String:[Position]], limit: Int) -> Set<Position> {
    var antinodes = Set<Position>()
    for (_, positions) in signals {
        for i1 in 0..<positions.count-1 {
            for i2 in i1+1..<positions.count {
                let p1 = positions[i1]
                let p2 = positions[i2]

                for l in 0...limit {
                    let antinode1 = Position(x: p1.x - l * (p2.x - p1.x), y: p1.y - l * (p2.y - p1.y))
                    if (antinode1.x >= 0 && antinode1.x < width && antinode1.y >= 0 && antinode1.y < height) {
                        antinodes.insert(antinode1)
                    }
                    else {
                        break
                    }
                }
                for l in 0...limit {
                    let antinode2 = Position(x: p2.x + l * (p2.x - p1.x), y: p2.y + l * (p2.y - p1.y))
                    if (antinode2.x >= 0 && antinode2.x < width && antinode2.y >= 0 && antinode2.y < height) {
                        antinodes.insert(antinode2)
                    }
                    else {
                        break
                    }
                }
            }
        }		    
    }
    return antinodes
}

let regularAntinodes = findAntinodes(signals, limit: 1)
print("Total number of antinodes: \(regularAntinodes.count)")
// var regularAntinodeMap = map
// for a in regularAntinodes {
//     if regularAntinodeMap[a.y][a.x] == "." {
//         regularAntinodeMap[a.y][a.x] = "#"        
//     }
// }
// print(map: regularAntinodeMap)
// print()

let resonantAntinodes = findAntinodes(signals, limit: 999)
print("Total number of resonant antinodes: \(resonantAntinodes.count)")
// var resonantAntinodeMap = map
// for a in resonantAntinodes {
//     if resonantAntinodeMap[a.y][a.x] == "." {
//         resonantAntinodeMap[a.y][a.x] = "#"        
//     }
// }
// print(map: resonantAntinodeMap)
