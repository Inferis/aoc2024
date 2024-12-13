#!/usr/bin/swift -enable-bare-slash-regex

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Position: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        get {
            "(\(x),\(y))"
        }
    }

    static var zero = Position(x: 0, y: 0)
}

struct Button: CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        get {
            "(+\(x), +\(y))"
        }
    }
    
    static let zero = Button(x: 0, y: 0)
}

func ==(a: Position, b: Position) -> Bool {
    return a.x == b.x && a.y == b.y
}

class Machine: CustomStringConvertible {
    let aButton: Button
    let bButton: Button
    var prize: Position
    var solution: (Int, Int)?
    var solved: Bool

    init(aButton: Button, bButton: Button, prize: Position) {
        self.aButton = aButton
        self.bButton = bButton
        self.prize = prize
        solution = nil 
        solved = false
    }

    func expand() {
        prize = Position(x: prize.x + 10000000000000, y: prize.y + 10000000000000)
        solved = false 
        solution = nil
    }

    func solveIfNeeded() {
        if !solved {
            var value = aButton.x * prize.y - aButton.y * prize.x
            let divider = aButton.x * bButton.y - aButton.y * bButton.x
            let bRemainder = value % divider
            if bRemainder == 0 {
                let bQuotient = value / divider
                value = prize.x - bQuotient * bButton.x
                let aRemainder = value % aButton.x
                if aRemainder == 0 {
                    let aQuotient = value / aButton.x
                    solution = (aQuotient, bQuotient)
                    solved = true
                }
            }
        }
    }

    var tokensNeeded: Int {
        solveIfNeeded()
        if let solution {
            return 3 * solution.0 + solution.1
        }
        else {
            return 0
        }
    }

    var description: String { 
        get {
            "{a: \(aButton), b: \(bButton) -> \(prize)} = \(solution != nil ? "\(solution!)" : "none")"
        }
    }
}

let buttonRegex = /Button .: X\+([0-9]+), Y\+([0-9]+)/
let prizeRegex = /Prize: X=([0-9]+), Y=([0-9]+)/
let machines = input.split(separator: "\n\n").map({ source in 
    let lines = source.split(separator: "\n")
    var a: Button = .zero
    if let buttonAMatch = try? buttonRegex.firstMatch(in: lines[0]) {
        a = Button(x: Int(buttonAMatch.1)!, y: Int(buttonAMatch.2)!)
    }
    var b: Button = .zero
    if let buttonBMatch = try? buttonRegex.firstMatch(in: lines[1]) {
        b = Button(x: Int(buttonBMatch.1)!, y: Int(buttonBMatch.2)!)
    }
    var prize: Position = .zero
    if let prizeMatch = try? prizeRegex.firstMatch(in: lines[2]) {
        prize = Position(x: Int(prizeMatch.1)!, y: Int(prizeMatch.2)!)
    }
    return Machine(aButton: a, bButton: b, prize: prize)
})

var totalTokens = 0 
for machine in machines {
    let tokens = machine.tokensNeeded
    totalTokens += tokens
}
print("Part1: Total tokens needed: \(totalTokens)")

totalTokens = 0 
for machine in machines {
    machine.expand()
    let tokens = machine.tokensNeeded
    totalTokens += tokens
}
print("Part2: Total tokens needed: \(totalTokens)")
