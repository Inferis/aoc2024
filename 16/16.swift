#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int

    func dx(_ delta: Int) -> Position {
        Position(x: x + delta, y: y)
    }

    func dy(_ delta: Int) -> Position {
        Position(x: x, y: y + delta)
    }

    func move(_ orientation: Orientation) -> Position {
        switch orientation {
            case .north: return self.dy(-1)
            case .south: return self.dy(+1)
            case .east: return self.dx(+1)
            case .west: return self.dx(-1)
        }
    }
    static let zero: Position = Position(x: 0, y: 0) 

    var description: String {
        get {
            "(\(x),\(y))"
        }
    }
}

func ==(a: Position, b: Position) -> Bool {
    return a.x == b.x && a.y == b.y
}

enum Orientation: CustomStringConvertible {
    case north
    case south
    case east
    case west

    var rotatedClockwise: Orientation {
        get {
            switch self {
                case .north: return .east
                case .south: return .west
                case .east: return .south
                case .west: return .north
            }
        }
    }

    var rotatedCounterClockwise: Orientation {
        get {
            switch self {
                case .north: return .west
                case .south: return .east
                case .east: return .north
                case .west: return .south
            }
        }
    }

    var description: String {
        get {
            switch self {
                case .north: return "N"
                case .south: return "S"
                case .east:  return "E"
                case .west:  return "W"
            }
        }
    }
}

enum Step: CustomStringConvertible {
    case forward
    case rotateClockwise
    case rotateCounterClockwise

    var description: String {
        get {
            switch self {
                case .forward: return "^"
                case .rotateClockwise: return ">"
                case .rotateCounterClockwise:  return "<"
            }
        }
    }
}

struct Path: Equatable, CustomStringConvertible, Comparable {
    let start: Position
    let startOrientation: Orientation 
    var steps: [Step]

    init(start: Position, orientation: Orientation) {
        self.start = start
        self.startOrientation = orientation
        self.steps = []
    }

    init(path: Path, steps: [Step]) {
        self.start = path.start
        self.startOrientation = path.startOrientation
        self.steps = path.steps + steps
    }

    var end: Position {
        get {
            positions().last!
        }
    }

    var endOrientation: Orientation {
        get {
            orientations().last!
        }
    }

    var score: Int {
        get {
            var score = 0
            for step in steps {
                if step == .forward {
                    score += 1
                }
                else {
                    score += 1001
                }
            }
            return score
        }
    }

    func positions() -> [Position] {
        var positions: [Position] = [start]
        var position = start
        var orientation = startOrientation
        for step in steps {
            orientation = nextOrientation(for: orientation, step: step)
            position = nextPosition(from: position, orientation: orientation)
            positions.append(position)
        }
        return positions
    }

    func orientations() -> [Orientation] {
        var orientations: [Orientation] = [startOrientation]
        var orientation = startOrientation
        for step in steps {
            orientation = nextOrientation(for: orientation, step: step)
            orientations.append(orientation)
        }
        return orientations
    }

    func nextOrientation(for orientation: Orientation, step: Step) -> Orientation {
        switch step {
            case .forward: return orientation
            case .rotateClockwise: return orientation.rotatedClockwise
            case .rotateCounterClockwise: return orientation.rotatedCounterClockwise
        }
    }

    func nextPosition(from position: Position, orientation: Orientation) -> Position {
        return position.move(orientation)
    }

    var description: String {
        get {
            "\(start) \(steps.map({ $0.description }).joined(separator: "")) \(end) #\(score)"
        }
    }
}

func ==(a: Path, b: Path) -> Bool {
    return a.start == b.start && a.startOrientation == b.startOrientation && a.steps == b.steps
}

func <(a: Path, b: Path) -> Bool {
    return a.score < b.score
}

struct Map: CustomStringConvertible {
    var map: [[String]]
    let height: Int 
    let width: Int
    let start: Position? 
    let end: Position?
    let startPath: Path?

    init(input: String) {
        map = input.split(separator: "\n").map({ $0.split(separator: "").map({ String($0) }) })
        width = map.first?.count ?? 0
        height = map.count    
        var startPos: Position?
        var endPos: Position?
        for y in 0..<height {
            for x in 0..<width {
                if map[y][x] == "S" {
                    map[y][x] = "o"
                    startPos = Position(x: x, y: y)
                }
                else if map[y][x] == "E" {
                    map[y][x] = "."
                    endPos = Position(x: x, y: y)
                }
            }
        }
        start = startPos
        end = endPos

        if let start { 
            startPath = Path(start: start, orientation: .east)
        }
        else {
            startPath = nil
        }

        assert(start != nil)
        assert(end != nil)
    }

    subscript(index: Position) -> String {
        get {
            map[index.y][index.x]
        }
        set(newValue) {
            map[index.y][index.x] = newValue
        }
    }

    func paths(from path: Path) -> [Path] {
        var paths: [Path] = []

        if path.end == end {
            return [path]
        }

        var map = self
        map.mark(path: path)

        // check forward
        let end = path.end
        let forwardPosition = end.move(path.endOrientation)
        if map[forwardPosition] == "." {
            paths.append(Path(path: path, steps: [.forward]))
        }
        // rotate clockwise
        let rotateClockwisePosition = end.move(path.endOrientation.rotatedClockwise)
        if map[rotateClockwisePosition] == "." {
            paths.append(Path(path: path, steps: [.rotateClockwise, .forward]))
        }
        // rotate counter clockwise
        let rotateCounterClockwisePosition = end.move(path.endOrientation.rotatedCounterClockwise)
        if map[rotateCounterClockwisePosition] == "." {
            paths.append(Path(path: path, steps: [.rotateCounterClockwise, .forward]))
        }

        return paths
    }

    mutating func mark(path: Path) {
        for position in path.positions() {
            self[position] = "o"
        }
    }

    var description: String {
        get {
            map.map({ $0.joined(separator: "") }).joined(separator: "\n")
        }
    }
}

let map = Map(input: input)
print("Source:")
print(map)
if let startPath = map.startPath {
    var paths = [startPath]
    var previousPaths: [Path] = []
    
    while previousPaths != paths {
        print(paths.count)
        previousPaths = paths
        paths = []
        for path in previousPaths {
            let newPaths = map.paths(from: path)
            paths.append(contentsOf: newPaths)
        }
    }    

    print()
    print("All paths:")
    paths.sort()
    for path in paths {
        print(path)
    }

    print()
    print("Result:")
    var map = map
    if let shortest = paths.first {
        map.mark(path: shortest)
        print(map)
        print(shortest)
    }

}


