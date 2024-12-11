#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
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

class Trailhead: CustomStringConvertible {
    let start: Position
    var trails: [Trail]

    init(map: [[Int]], start: Position) {
        self.start = start 
        self.trails = []
        trails.append(Trail(map: map, trailhead: self))
    }

    func allTrailsEnded() -> Bool {
        trails.reduce(true, { $0 && $1.isAtEnd() })
    }

    func distinctTrails() -> [Trail] {
        var result = trails
        var foundEnd: [Position] = []
        result.removeAll { trail in
            let last = trail.steps.last!
            if foundEnd.contains(where: { $0 == last }) {
                return true
            }
            else {
                foundEnd.append(last)
                return false
            }
        }
        return result
    }

    var score: Int {
        get {
            return distinctTrails().count
        }
    }

    var rating: Int {
        get {
            return trails.count
        }
    }

    var description: String {
        get {
            var description = "(\(start.x), \(start.y)) -> \(trails.count) trails\n"
            for trail in trails {
                description.append("\t\(trail)\n")
            }
            return description
        }
    }
}

class Trail: CustomStringConvertible {
    let id: UUID
    let map: [[Int]]
    let trailhead: Trailhead
    let start: Position
    var steps: [Position]

    init(map: [[Int]], trailhead: Trailhead) {
        self.id = UUID()
        self.map = map
        self.trailhead = trailhead
        self.start = trailhead.start
        self.steps = [start]
    }

    init(trail: Trail, step: Position) {
        id = UUID()
        map = trail.map
        trailhead = trail.trailhead
        start = trail.start
        steps = trail.steps
        steps.append(step)       
    }

    func isAtEnd() -> Bool {
        let end = steps.last! 
        return map[end.y][end.x] >= 9
    }

    func step() {
        let current = steps.last!
        let height = map[current.y][current.x]
        let nextHeight = height + 1
        var trails: [Trail] = []

        if current.y-1 >= 0 && map[current.y-1][current.x] == nextHeight {
            let trail = Trail(trail: self, step: Position(x: current.x, y: current.y-1))
            trails.append(trail)
        }
        if current.y+1 < map.count && map[current.y+1][current.x] == nextHeight {
            let trail = Trail(trail: self, step: Position(x: current.x, y: current.y+1))
            trails.append(trail)
        }
        if current.x-1 >= 0 && map[current.y][current.x-1] == nextHeight {
            let trail = Trail(trail: self, step: Position(x: current.x-1, y: current.y))
            trails.append(trail)
        }
        if current.x+1 < map[0].count && map[current.y][current.x+1] == nextHeight {
            let trail = Trail(trail: self, step: Position(x: current.x+1, y: current.y))
            trails.append(trail)
        }

        if let trail = trails.first {
            steps = trail.steps
            trails.removeFirst()
        }
        else {
            // dead end
            trailhead.trails.remove(at: trailhead.trails.firstIndex(where: { $0.id == self.id })!)
        }

        trailhead.trails.append(contentsOf: trails)
    }

    var description: String {
        get {
            steps.map({ "(\($0.x),\($0.y):\(map[$0.y][$0.x]))" }).joined(separator: "->")
        }
    }
}

let map = input.split(separator: "\n").map({ $0.split(separator: "").map({ Int(String($0))! }) })

var trailheads: [Trailhead] = []
for y in 0..<map.count {
    for x in 0..<map[y].count {
        if map[y][x] == 0 {
            let trailhead = Trailhead(map: map, start: Position(x: x, y: y))
            trailheads.append(trailhead)
        }
    }
}

while !trailheads.reduce(true, { $0 && $1.allTrailsEnded() }) {
    for trail in trailheads.flatMap({ $0.trails }) {
        trail.step()
    }
}

print("Total score: \(trailheads.reduce(0, { $0 + $1.score }))")
print("Total rating: \(trailheads.reduce(0, { $0 + $1.rating }))")
