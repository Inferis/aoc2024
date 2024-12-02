import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Report: CustomStringConvertible {
    let levels: [Int]

    init(line: String.SubSequence) {
        levels = line.split(separator: " ").compactMap({ Int($0) })
    }   

    func isSafe(values: [Int]) -> Bool {
        if values.count <= 1 {
            return true
        }

        var isAscending: Bool? = nil
        for i in 1..<values.count {
            if values[i] == values[i-1] {
                return false // must be different by at least one
            }

            if abs(values[i-1] - values[i]) > 3 {
                return false // can't have more than 3 different
            }

            if let isAscending {
                if isAscending != (values[i-1] < values[i]) {
                    return false
                } 
            }
            else {
                if values[i-1] > values[i] {
                    isAscending = false
                }
                else if values[i-1] < values[i] {
                    isAscending = true
                }
            }
        }

        return true
    }   

    func isSafe() -> Bool {
        return isSafe(values: levels)
    }   

    func isDampenedSafe() -> Bool {
        if (isSafe(values: levels)) { 
            return true 
        }

        for i in 0..<levels.count {
            var values = levels
            values.remove(at: i)
            if (isSafe(values: values)) {
                return true
            }
        }

        return false
    }

    var description: String { 
        get {
            return levels.map({ "\($0)" }).joined(separator: " -> ") 
        }  
    }
}

let reports: [Report] = input.split(separator: "\n").map({ Report(line: $0) })

print("Number of truly safe reports: \(reports.filter({ $0.isSafe() }).count)")
print("Number of dampened safe reports: \(reports.filter({ $0.isDampenedSafe() }).count)")