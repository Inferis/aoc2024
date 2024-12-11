#!/usr/bin/swift

import Foundation

var file = (CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : nil) ?? "input.txt"

guard let input = try? String(contentsOf:URL(filePath: file), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

print(input.count)

struct Disk: CustomStringConvertible {
    var layout: [DiskItem]

    init(layout: [DiskItem]) {
        self.layout = layout
    }

    init(input: String) {
        var isFile = true
        var id = 0
        var layout: [DiskItem] = []
        for i in input.split(separator: "") {
            if let count = Int(i) {
                if isFile {
                    layout.append(DiskItem.file(id: id, count: count))
                }
                else {
                    layout.append(DiskItem.space(count: count))
                }
                if isFile { 
                    id += 1
                }
                isFile = !isFile
            }
        }
        self.layout = layout
    }

    func compress() -> Disk {
        var i = 0
        var compressed: [DiskItem] = layout
        while true {
            i += 1
            if i % 250 == 0 {
                print("\(i), \(Int(Float(i) / Float(layout.count) * 100.0))%")
            }
            let spaces = compressed.filter({ !$0.isFile })
            if spaces.count == 0 {
                // no space to compress, bail
                break
            } 
            else if spaces.count == 1 && spaces.first == layout.last {
                // last item is remaining space, stop
                break
            }

            if let lastFile = compressed.filter({ $0.isFile }).last, 
               let lastFileIndex = compressed.lastIndex(of: lastFile),
               let firstSpace = compressed.filter({ !$0.isFile }).first,
               let firstSpaceIndex = compressed.firstIndex(of: firstSpace) {
                if lastFileIndex < firstSpaceIndex {
                    // We only have space left at the end, so stop
                    compressed = Disk.consolidate(layout: compressed)
                    break
                }

                compressed.remove(at: lastFileIndex)
                var newFile: DiskItem? = nil
                if lastFile.count > 1 {
                    newFile = lastFile.shrink()
                    if newFile != nil {
                        compressed.insert(lastFile, at: lastFileIndex)
                    }
                    else {
                        newFile = lastFile
                    }
                }
                else {
                    newFile = lastFile
                }

                if firstSpace.count > 1 {
                    _ = firstSpace.shrink()
                }
                else {
                    compressed.remove(at: firstSpaceIndex)
                }

                if let newFile {
                    compressed.insert(newFile, at: firstSpaceIndex)
                }

                // add empty whitespace at end
                compressed.append(DiskItem.space())

                // Consolidate
                compressed = Disk.consolidate(layout: compressed)
            }
        }
        return Disk(layout: compressed)
    }

    static func consolidate(layout: [DiskItem]) -> [DiskItem] {
        var i = 0
        var consolidating = layout
        while i < consolidating.count - 1 {
            if consolidating[i].id == consolidating[i+1].id {
                consolidating[i].count += consolidating[i+1].count 
                consolidating.remove(at: i+1)
            } 
            else {
                i += 1
            }
        }
        return consolidating
    }
    
    var checksum: Int {
        var checksum = 0
        var i = 0
        for item in layout {
            for _ in 0..<item.count {
                checksum += i * item.id
                i += 1
            }
        }
        return checksum
    }

    var description: String {
        get {
            var description = ""
            for item in layout {
                if item.isFile {
                    description.append("[")
                    description.append(Array(repeating: "\(item.id)", count: item.count).joined(separator: "|"))
                    description.append("]")
                }
                else {
                    description.append("{")
                    description.append(String(repeating: ".", count: item.count))
                    description.append("}")
                }
            }
            description.append("(\(checksum))")
            return description
        }
    }
}

class DiskItem: Equatable {
    let id: Int
    let isFile: Bool
    var count: Int

    init(id: Int, isFile: Bool, count: Int) {
        self.id = id
        self.isFile = isFile
        self.count = count
    }

    func shrink() -> DiskItem {
        assert(count > 0, "count == 0 for \(isFile ? "file" : "free") \(id)")
        count -= 1
        return DiskItem(id: id, isFile: isFile, count: 1)
    }

    static func file(id: Int, count: Int = 1) -> DiskItem {
        DiskItem(id: id, isFile: true, count: count)
    }

    static func space(count: Int = 1) -> DiskItem {
        DiskItem(id: 0, isFile: false, count: count)
    } 
}

func ==(a: DiskItem, b: DiskItem) -> Bool {
    return a.id == b.id && a.isFile == b.isFile && a.count == b.count
}

var disk = Disk(input: input)
print(disk)
print()
disk = disk.compress()
print()
print(disk)
