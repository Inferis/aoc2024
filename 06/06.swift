#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "smallinput.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable {
    let x: Int
    let y: Int
}

func ==(a: Position, b: Position) -> Bool {
    return a.x == b.x && a.y == b.y
}

func positionOfGuard(on map: [[String]]) -> Position? {
    for y in 0..<map.count {
        for x in 0..<map[y].count {
            if map[y][x] == "^" || map[y][x] == "<" || map[y][x] == ">" || map[y][x] == "v" {
                return Position(x: x, y: y)
            }
        }
    }
    return nil
}

func directionOf(guard: String) -> (x: Int, y: Int) {
    switch `guard` {
        case "^": return (0, -1)
        case "v": return (0, 1)
        case "<": return (-1, 0)
        case ">": return (1, 0)
        default: return (0, 0)
    }
}

func rotated(guard: String) -> String {
    switch `guard` {
        case "^": return ">"
        case "v": return "<"
        case "<": return "^"
        case ">": return "v"
        default: return `guard`
    }
}

func withinMapBounds(position: Position) -> Bool {
    position.x >= 0 && position.x < map[0].count && position.y >= 0 && position.y < map.count 
}

func print(map: [[String]]) {
    print(map.map({ $0.joined(separator: "") }).joined(separator: "\n"))
}

struct Traversal {
    let exited: Bool
    let map: [[String]]
    let crossings: [Position]
}

func traverse(map freshMap: [[String]]) -> Traversal {
    var crossings: [Position] = []
    var map = freshMap
    let startPosition = positionOfGuard(on: map)
    if var position = startPosition {
        let startDirection =  directionOf(guard: map[position.y][position.x])
        while withinMapBounds(position: position) {
            let `guard` = map[position.y][position.x]
            let direction = directionOf(guard: `guard`)
            let newPosition = Position(x: position.x + direction.x, y: position.y + direction.y)

            // check if we're still on the map
            if !withinMapBounds(position: newPosition) {
                break
            }
            
            if map[newPosition.y][newPosition.x] == "#" {
                // obstacle: rotate
                map[position.y][position.x] = rotated(guard: map[position.y][position.x])
            }
            else {
                print(map[newPosition.y][newPosition.x])
                if map[newPosition.y][newPosition.x] == "X" {
                    crossings.append(newPosition)
                }
                map[position.y][position.x] = "X"
                map[newPosition.y][newPosition.x] = `guard`
                position = newPosition
            }
        }
        map[position.y][position.x] = "X"
    }
    return Traversal(exited: true, map: map, crossings: crossings)
}

let map = input.split(separator: "\n").map({ line in line.split(separator: "").map({ String($0) }) })
let traversal = traverse(map: map)
print(traversal.exited)
print(map: traversal.map)
print(traversal.crossings)

var countVisited = 0
for line in traversal.map {
    for position in line {
        if position == "X" {
            countVisited += 1
        }
    }
}
print("Total number of places visited: \(countVisited)") 
