//
//  DocumentManager.swift
//  ChineseLearning
//
//  Created by feiyue on 31/03/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import CocoaLumberjack

class DocumentManager:NSObject {
    class func urlFromFilename(filename:String) -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent(filename)
        return documentsDirectory
        //var path = URL(string: NSTemporaryDirectory())!
        //path.appendPathComponent(filename)
        //return path
    }
    
    class func getCacheFolderSize() -> Int {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        var bool: ObjCBool = false

        if FileManager.default.fileExists(atPath: documentsDirectory.path, isDirectory: &bool), bool.boolValue  {
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
                var folderFileSizeInBytes: UInt64 = 0
                for file in files {
                    
                    folderFileSizeInBytes += (try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? NSNumber)??.uint64Value ?? 0
                }
                return Int(folderFileSizeInBytes)
            } catch let error as NSError {
                DDLogInfo(error.localizedDescription)
            }
        }
        return 0
    }
    
    class func renameFile(oldName: String, newName: String) {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        let oldPath = documentsDirectory.appendingPathComponent(oldName)
        let newPath = documentsDirectory.appendingPathComponent(newName)
        do {
            try FileManager.default.removeItem(at: newPath)
        } catch {
            DDLogInfo(error.localizedDescription)
        }
        do {
            try FileManager.default.copyItem(at: oldPath, to: newPath)
        } catch{
            DDLogInfo(error.localizedDescription)
        }
    }
    
    class func clearCache() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        var bool: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: documentsDirectory.path, isDirectory: &bool), bool.boolValue  {
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
                for file in files {
                    if file.path.hasSuffix("DS_Store") {
                        continue
                    }
                    try FileManager.default.removeItem(atPath: file.path)
                }
            } catch let error as NSError {
                DDLogInfo(error.localizedDescription + "ok")
            }
        }

    }
}
