#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    func move(_ direction: String) -> Position {
        switch direction {
            case "^": return Position(x: x, y: y-1)
            case "v": return Position(x: x, y: y+1)
            case "<": return Position(x: x-1, y: y)
            case ">": return Position(x: x+1, y: y)
            default: return self
        }
    }

    func dx(_ delta: Int) -> Position {
        Position(x: x + delta, y: y)
    }

    func dy(_ delta: Int) -> Position {
        Position(x: x, y: y + delta)
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

class Map: CustomStringConvertible {
    var map: [Position:String]
    let width: Int
    let height: Int
    var robot: Position?
    let isExpanded: Bool
    var moved: Bool

    init(map: [[String]], expand: Bool = false) {
        self.map = [:]
        let factor = expand ? 2 : 1
        width = map[0].count * factor
        height = map.count
        isExpanded = expand
        moved = true
        for y in 0..<height {
            for x in 0..<width / factor {
                let m = map[y][x]
                if m != "." {
                    if expand {
                        if m == "#" {
                            self.map[Position(x: x * factor, y: y)] = m
                            self.map[Position(x: x * factor + 1, y: y)] = m
                        }
                        else if m == "O" {
                            self.map[Position(x: x * factor, y: y)] = "["
                            self.map[Position(x: x * factor + 1, y: y)] = "]"
                        }
                        else {
                            self.map[Position(x: x * factor, y: y)] = m
                        }
                    }
                    else {
                        self.map[Position(x: x * factor, y: y)] = m
                    }
                    if m == "@" {
                        robot = Position(x: x * factor, y: y)
                    }
                }
            }
        }
    }

    func isVertical(direction: String) -> Bool {
        return direction == "^" || direction == "v"
    }

    func moveRobot(direction: String) {
        moved = false
        guard let robot else { return }
        let newPosition = robot.move(direction)
        if at(newPosition) == "." {
            set(at: newPosition, "@")
            set(at: robot, nil)
            moved = true
            self.robot = newPosition
            return
        }
        else if isBox(newPosition) {
            if isExpanded {
                if isVertical(direction: direction) {
                    let startPosition = boxPosition(at: newPosition) 
                    let startPosition2 = startPosition.dx(1)
                    var freePosition = startPosition
                    var freePosition2 = startPosition2
                    while at(freePosition) == at(startPosition) && at(freePosition2) == at(startPosition2) {
                        freePosition = freePosition.move(direction) 
                        freePosition2 = freePosition2.move(direction) 
                    }
                    if isEmpty(freePosition) && isEmpty(freePosition2) {
                        let boxPosition = boxPosition(at: newPosition)
                        if boxPosition.y < freePosition.y {
                            clear(at: boxPosition)
                            clear(at: robot)
                            set(at: newPosition, "@")
                            moved = true   
                            for y in boxPosition.y+1...freePosition.y {
                                setBox(at: Position(x: boxPosition.x, y: y))
                            }
                        }
                        else {
                            clear(at: boxPosition)
                            clear(at: robot)
                            set(at: newPosition, "@")
                            moved = true   
                            for y in freePosition.y...boxPosition.y-1 {
                                setBox(at: Position(x: boxPosition.x, y: y))
                            }
                        }
                        self.robot = newPosition
                    }
                }
                else {
                    var freePosition = newPosition 
                    while isBox(freePosition) {
                        freePosition = freePosition.move(direction) 
                    }
                    if isEmpty(freePosition) {
                        clear(at: robot)
                        set(at: newPosition, "@")
                        moved = true   
                        if newPosition.x < freePosition.x {
                            for x in stride(from:newPosition.x + 1, to: freePosition.x, by: 2) {
                                setBox(at: Position(x: x, y: newPosition.y))
                            }
                        }
                        else if newPosition.x > freePosition.x {
                            for x in stride(from:freePosition.x, to: newPosition.x - 1, by: 2) {
                                setBox(at: Position(x: x, y: newPosition.y))
                            }
                        }
                        self.robot = newPosition
                    }
                }
            }
            else {
                var freePosition = newPosition 
                while isBox(freePosition) {
                    freePosition = freePosition.move(direction) 
                }
                if isEmpty(freePosition) {
                    setBox(at: freePosition)
                    set(at: newPosition, "@")
                    set(at: robot, nil)
                    moved = true   
                    self.robot = newPosition
                }
            }
        }
    }

    func boxPosition(at: Position) -> Position {
        if isExpanded && self.at(at) == "]" {
            return Position(x: at.x-1, y: at.y)
        }
        return at
    }

    func boxPositions(at: Position) -> [Position] {
        if isExpanded { 
            if (self.at(at) == "]") {
                return [at.dx(-1), at]
            }
            else {
                return [at, at.dx(+1)]
            }
        }
        return [at]
    }

    func isBox(_ at: Position) -> Bool {
        if isExpanded {
            return self.at(at) == "[" || self.at(at) == "]"
        }
        else {
            return self.at(at) == "O"
        }
    }

    func setBox(at: Position) {
        if isExpanded {
            set(at: at, "[")
            set(at: Position(x: at.x + 1, y: at.y), "]")
        }
        else {
            set(at: at, "O")
        }
    }

    func clear(at: Position) {
        if isExpanded {
            if self.at(at) == "[" {
                set(at: at, nil)
                set(at: at.dx(1), nil)
            }
            else if self.at(at) == "]" {
                set(at: at, nil)
                set(at: at.dx(-1), nil)
            }
            else {
                set(at: at, nil)
            }
        }        
        else {
            set(at: at, nil)
        }
    }

    func isEmpty(_ at: Position) -> Bool {
        self.at(at) == "."
    }

    func at(_ at: Position) -> String {
        if let place = map[at] {
            return place
        }
        else {
            return "."
        }
    }

    func set(at: Position, _ value: String?) {
        map[at] = value
    }

    var gps: Int {
        get {
            let box = isExpanded ? "[" : "O"
            var gps = 0
            for y in 0..<height {
                for x in 0..<width {
                    if at(Position(x: x, y: y)) == box {
                        gps += y * 100 + x
                    }
                }
            }
            return gps           
        }
    }

    var description: String {
        get {
            var result = ""
            for y in 0..<height {
                for x in 0..<width {
                    if let place = map[Position(x: x, y: y)] {
                        if place == "@" {
                            result.append("\u{1b}[1m")
                            if moved {
                                result.append("\u{1b}[32m")
                            }
                            else {
                                result.append("\u{1b}[31m")
                            }
                            result.append(place)
                            result.append("\u{1b}[0m")
                        }
                        else if place == "[" || place == "]" {
                            result.append("\u{1b}[30m")
                            result.append(place)
                            result.append("\u{1b}[0m")
                        }
                        else {
                            result.append(place)
                        }
                    }
                    else {
                        result.append(".")
                    }
                }
                if y < height - 1 {
                    result.append("\n")
                }
            }
            return result
        }
    }
}

let input2 = input.split(separator: "\n\n")
let map1 = Map(map: input2.first!.split(separator: "\n").map({ $0.split(separator: "").map({ String($0) }) }))
let map2 = Map(map: input2.first!.split(separator: "\n").map({ $0.split(separator: "").map({ String($0) }) }), expand: true)
let guide = input2.last!.split(separator: "").map({ String($0) })


for direction in guide {
    map1.moveRobot(direction: direction)
}
print(map1)
print(map1.gps)

print(map2)
var i = 0
for direction in guide {
//    print(direction)
    map2.moveRobot(direction: direction)
//    print(map2)
//    _ = readLine()
}
print(map2)
print(map2.gps)

