import Foundation

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

var listOne: [Int] = []
var listTwo: [Int] = []

for line in input.split(separator: "\n") {
    let values = String(line).split(separator: " ").map({ String($0) })
    if let stringValue = values.first, let intValue = Int(stringValue) {
        listOne.append(intValue)
    }
    if let stringValue = values.last, let intValue = Int(stringValue) {
        listTwo.append(intValue)
    }
}

listOne = listOne.sorted()
listTwo = listTwo.sorted()

assert(listOne.count == listTwo.count)

var totalDistance = 0
for i in 0..<listOne.count {
    let distance = abs(listOne[i] - listTwo[i])
    //print("\(listOne[i]) <> \(listTwo[i]) -> \(distance)")
    totalDistance += distance
}
print("Total Distance: \(totalDistance)")

// part 2

var totalScore = 0
for value in listOne {
    let count = listTwo.filter({ $0 == value }).count 
    let score = count * value
    totalScore += score
}

print("Similarity Score: \(totalScore)")
