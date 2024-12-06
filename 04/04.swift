#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let grid = input.split(separator: "\n").map({ $0.split(separator: "") })
let width = grid[0].count
let height = grid.count
let xmas = ["X", "M", "A", "S"]

var xmasCount = 0
for y in 0..<height {
    for x in 0..<width {
        for vy in [-1, 0, 1] {
            for vx in [-1, 0, 1] {
                var success = true
                for n in 0..<4 {
                    let dx = x + vx * n
                    let dy = y + vy * n
                    if dx >= 0 && dx < width && dy >= 0 && dy < height {
                        if grid[dy][dx] != xmas[n] {
                            success = false
                            break
                        }
                    }
                    else {
                        success = false
                        break
                    }
                }
                if success {
                    xmasCount += 1
                }
            }
        }
    }
}
print("Total number of XMAS: \(xmasCount)")

var masXCount = 0
for y in 0..<height-2 {
    for x in 0..<width-2 {
        if grid[y+1][x+1] == "A" {
            if grid[y][x] == "M" && grid[y][x+2] == "M" && grid[y+2][x] == "S" && grid[y+2][x+2] == "S" {
                // M M
                //  A
                // S S
                masXCount += 1                
            }
            else if grid[y][x] == "M" && grid[y][x+2] == "S" && grid[y+2][x] == "M" && grid[y+2][x+2] == "S" {
                // M S
                //  A
                // M S
                masXCount += 1                
            }
            else if grid[y][x] == "S" && grid[y][x+2] == "S" && grid[y+2][x] == "M" && grid[y+2][x+2] == "M" {
                // S S
                //  A
                // M M
                masXCount += 1                
            }
            else if grid[y][x] == "S" && grid[y][x+2] == "M" && grid[y+2][x] == "S" && grid[y+2][x+2] == "M" {
                // S M
                //  A
                // S M
                masXCount += 1                
            }
        }
    }
} 
print("Total number of mas-x's: \(masXCount)")