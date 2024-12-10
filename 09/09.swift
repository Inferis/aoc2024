#!/usr/bin/swift

import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

