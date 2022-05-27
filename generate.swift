// usage: swift generate.swift pokedex
// splits the json found in the folder into subfolders with each entry on the json
import Foundation

extension URL {
    
    var contentsOfDirectory: [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: self.absoluteString)) ?? []
    }
    var subURLS: [URL] {
        self.contentsOfDirectory.map({ 
            self.appendingPathComponent($0)
        })
    }
}

let ROOT = URL(string: FileManager.default.currentDirectoryPath)!

CommandLine.arguments.forEach({ folderName in

    let folder = ROOT.appendingPathComponent(folderName)

    folder.contentsOfDirectory.forEach { sub in
        let subfolder = folder.appendingPathComponent(sub)
        let filenames = subfolder.contentsOfDirectory.filter({ !$0.starts(with: ".") })

        filenames.forEach { filename in
            guard let string = try? String(contentsOfFile: subfolder.appendingPathComponent(filename).absoluteString, encoding: .utf8),
                  let data = string.data(using: .utf8, allowLossyConversion: true),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary]
            else { return }
            let basename = (filename as NSString).deletingPathExtension
            json.forEach { entry in
                guard let id = entry["id"] as? String else { return }
                let entryFolder = subfolder.appendingPathComponent(basename)
                let entryFile = entryFolder.appendingPathComponent("\(id).json")
                do {
                    try FileManager.default.createDirectory(atPath: entryFolder.absoluteString, withIntermediateDirectories: true)
                    try JSONSerialization
                        .data(withJSONObject: entry, options: [.prettyPrinted, .withoutEscapingSlashes])
                        .write(to: URL(fileURLWithPath: entryFile.absoluteString))
                } catch {
                    print(error)
                }
            }
            let schema: NSMutableDictionary = NSMutableDictionary(dictionary: json.first ?? [:])
            let schemaFile = subfolder.appendingPathComponent(".schema.json")
            schema.allKeys.forEach({ key in
                guard let key = key as? String else { return }
                let value = schema[key]
                if ((value as? Bool) != nil) {
                    schema.setValue("boolean", forKey: key)
                } else if ((value as? Int) != nil) {
                    schema.setValue("integer", forKey: key)
                } else if ((value as? Double) != nil) {
                    schema.setValue("double", forKey: key)
                } else if ((value as? String) != nil) {
                    schema.setValue("string", forKey: key)
                } else if ((value as? [Any]) != nil) {
                    schema.setValue("array", forKey: key)
                } else {
                    schema.setValue("unknown", forKey: key)
                }
            })
            do {
                try JSONSerialization
                    .data(withJSONObject: schema, options: .prettyPrinted)
                    .write(to: URL(fileURLWithPath: schemaFile.absoluteString))
            } catch {
                print(error)
            }
        }
    }

})