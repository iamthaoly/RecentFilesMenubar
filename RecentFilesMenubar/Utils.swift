//
//  Utils.swift
//  RecentFilesMenubar
//
//  Created by ly on 18/08/2022.
//

import Foundation
import QuickLookThumbnailing
import AppKit

class Utils {
    
//    static func generateThumbnail(url: URL, thumb: (CGImage?) -> ()) {
//        
//        let size: CGSize = CGSize(width: 60, height: 90)
//        let scale = NSScreen.main?.backingScaleFactor
//        
//        // Create the thumbnail request.
//        let request = QLThumbnailGenerator.Request(fileAt: url,
//                                                   size: size,
//                                                   scale: scale ?? 1,
//                                                   representationTypes: .all)
//        
//        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
//        var thumbnailResult: CGImage? = nil
//        let generator = QLThumbnailGenerator.shared
//        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
//                if thumbnail == nil || error != nil {
//                    // Handle the error case gracefully.
//                    thumb()
////                    return nil
//                } else {
//                    // Display the thumbnail that you created.
//                    thumb(thumbnail?.cgImage)
//                }
//        }
//        
////        return thumbnailResult
//    }
    
    static func sizeForLocalFilePath(filePath: String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    static func convertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }

    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func getFileSize() -> UInt8 {
        return 0
    }
}
