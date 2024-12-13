#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, Hashable, Comparable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        get {
            "(\(x),\(y))"
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

struct Zone: CustomStringConvertible {
    let id: String 
    let positions: [Position]
    let fences: Int

    init(id: String, positions: [Position], fences: Int) {
        self.id = id
        self.positions = positions
        self.fences = fences
    }

    var price: Int {
        get {
            positions.count * fences
        }
    }

    var description: String {
        get {
            "\(id) {\(price)}: |\(fences)| #\(positions)#"
        }
    }
}

func print(map: [[String]]) {
    print(map.map({ $0.joined(separator: "") }).joined(separator: "\n"))
}

func findUnvisited() -> Position? {
    for y in 0..<height {
        for x in 0..<width {
            if visited[y][x] == "." {
                return Position(x: x, y: y)
            }
        }
    }
    return nil
}

let map = input.split(separator: "\n").map({ $0.split(separator: "" ).map({ String($0) }) })
var visited = map.map({ $0.map({ _ in "." }) })
let width = visited[0].count
let height = visited.count
var zones: [Zone] = []

while true {
    // find first unvisited square
    if let start = findUnvisited() {
        let zone = map[start.y][start.x]
        var area = 0
        var positions = [start] 
        var i = 0
        var zonePositions: [Position] = []
        var zoneFences = 0
        while positions.count > 0, i < 10 {
            i += 1
            area += positions.count
            var newPositions = Set<Position>()
            var newFences: [Position] = []
            for position in positions {
                visited[position.y][position.x] = "X"
                var p = Position(x: position.x, y: position.y-1)
                if position.y > 0 && map[p.y][p.x] == zone && visited[p.y][p.x] == "." {
                    newPositions.insert(p)                    
                } 
                else if position.y == 0 || map[p.y][p.x] != zone {
                    // print(position.x, position.y-1)
                    newFences.append(p)
                }

                p = Position(x: position.x, y: position.y+1)
                if position.y < height-1 && map[p.y][p.x] == zone && visited[p.y][p.x] == "." {
                    newPositions.insert(p)                    
                } 
                else if (position.y >= height-1 || map[p.y][p.x] != zone) {
                    // print(position.x, position.y+1)
                    newFences.append(p)
                }
                p = Position(x: position.x-1, y: position.y)
                if position.x > 0 && map[p.y][p.x] == zone && visited[p.y][p.x] == "." {
                    newPositions.insert(p)                    
                } 
                else if position.x == 0 || map[p.y][p.x] != zone {
                    // print(position.x-1, position.y)
                    newFences.append(p)
                }
                p = Position(x: position.x+1, y: position.y)
                if position.x < width-1 && map[p.y][p.x] == zone && visited[p.y][p.x] == "." {
                    newPositions.insert(p)                    
                } 
                else if position.x >= width-1 || map[p.y][p.x] != zone {
                    // print(position.x+1, position.y)
                    newFences.append(p)
                }
            }
            print("nf = ", positions, newFences)
            zonePositions.append(contentsOf: positions)
            zoneFences += newFences.count
            positions = Array(newPositions)
        }
        // print(zonePositions)
        // print(zoneFences)
        print(map: visited)
        zones.append(Zone(id: zone, positions: zonePositions, fences: zoneFences))
    }
    else {
        // everything found
        break
    }
}
for zone in zones {
    print(zone)
}
print(zones.reduce(0, { $0 + $1.price }))