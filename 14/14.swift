#!/usr/bin/swift -enable-bare-slash-regex

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, Hashable {
    let x: Int
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static let zero: Position = Position(x: 0, y: 0) 
}

func ==(a: Position, b: Position) -> Bool {
    return a.x == b.x && a.y == b.y
}

struct Vector: Equatable {
    let dx: Int
    let dy: Int

    static let zero: Vector = Vector(dx: 0, dy: 0) 
}

func ==(a: Vector, b: Vector) -> Bool {
    return a.dx == b.dx && a.dy == b.dy
}

class Robot: CustomStringConvertible {
    var position: Position
    let velocity: Vector

    init(line: String) {
        let regex = /p=([0-9]+),([0-9]+) v=([-0-9]+),([-0-9]+)/
        if let match = try? regex.firstMatch(in: line) {
            position = Position(x: Int(match.1)!, y: Int(match.2)!)
            velocity = Vector(dx: Int(match.3)!, dy: Int(match.4)!)
        } 
        else {
            position = .zero
            velocity = .zero
        }
    }

    func move(in: Map) {
        position = Position(x: (position.x + velocity.dx + map.width) % map.width, y: (position.y + velocity.dy + map.height) % map.height)
    }

    var description: String { 
        get {
            "{(\(position.x),\(position.y))->\(velocity.dx),\(velocity.dy)}"
        }
    }
}

struct Map: CustomStringConvertible {
    let width: Int
    let height: Int
    let robots: [Robot]

    var description: String { 
        get {
            var map = ""
            for y in 0..<height {
                for x in 0..<width {
                    let count = robots.filter({ $0.position.x == x && $0.position.y == y }).count
                    if count == 0 {
                        map.append(". ")
                    }
                    else {
                        map.append("\(count) ")
                    }
                }
                map.append("\n")
            }
            return map
        }
    }

    func quadrants() -> [[Robot]] {
        let halfWidth = (width-1) / 2
        let halfHeight = (height-1) / 2

        var result: [[Robot]] = []
        for sy in [0, halfHeight+1] {
            for sx in [0, halfWidth+1] {
                result.append(Array(robots.filter({ $0.position.x >= sx && $0.position.x < sx + halfWidth && $0.position.y >= sy && $0.position.y < sy + halfHeight })))
            }
        }
        return result
    }
}

let robots = input.split(separator: "\n").map({ Robot(line: String($0)) })
let map = Map(width: 101, height: 103, robots: robots)

for second in 1...100 {
    print(second)
    map.robots.forEach({ $0.move(in: map) })
}

print(map)
print(map.quadrants().map({ "\($0)" }).joined(separator: "\n"))
print(map.quadrants().map({ $0.count }).reduce(1, *))

for second in 101...20000 {
    print(second)
    map.robots.forEach({ $0.move(in: map) })
    let count = robots.reduce([:], { 
        var result = $0
        if result[$1.position] == nil {
            result[$1.position] = 0 
        }
        result[$1.position]! += 1
        return result
    }).values.filter({ $0 == 1 }).count
    if count == robots.count {
        print(map)
        break
    }
}

//print(map)

