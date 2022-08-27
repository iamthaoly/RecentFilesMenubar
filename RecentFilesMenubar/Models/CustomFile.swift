//
//  CustomFile.swift
//  RecentFilesMenubar
//
//  Created by ly on 17/08/2022.
//

import Foundation
import AppKit
import QuickLookThumbnailing

class CustomFile: Identifiable {
    let id = UUID()
    var fileName: String = ""
    var filePath: String = ""
    var dateAddedOrCreated: Date?
    var fileSize: UInt64?
    var thumbnail: CGImage?
    
    var readableFileSize: String {
        get {
            return Utils.convertToFileString(with: fileSize ?? 0)
        }
    }
    var parentFolder: String {
        get {
            let aboveDir = url.deletingLastPathComponent().path
            let folders = aboveDir.split(separator: "/")
            let parent = "\(folders.last ?? "")"
            return parent
        }
    }
    
    var url: URL
    
    init(filePath: String, strDate: String) {
        self.filePath = filePath
        self.url = URL.init(fileURLWithPath: filePath)
        self.fileName = url.lastPathComponent
        self.dateAddedOrCreated = strDate.toDate()
        self.fileSize = Utils.sizeForLocalFilePath(filePath: filePath)
        getThumb()
        
    }
    
    //    init(fileName: String, strDate: String) {
    //        self.fileName = fileName
    //        self.filePath = fileName
    //        self.url = URL.init(fileURLWithPath: filePath)
    //        self.dateAddedOrCreated = strDate.toDate()
    //    }
    
    private func getThumb() {
        let size: CGSize = CGSize(width: 60, height: 80)
        let scale = NSScreen.main?.backingScaleFactor
        
        // Create the thumbnail request.
        let request = QLThumbnailGenerator.Request(fileAt: url,
                                                   size: size,
                                                   scale: scale ?? 1,
                                                   representationTypes: .icon)
        
        // Retrieve the singleton instance of the thumbnail generator and generate the thumbnails.
        let generator = QLThumbnailGenerator.shared
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            if thumbnail == nil || error != nil {
                // Handle the error case gracefully.
                print("Error!")
                //                    return nil
            } else {
                // Display the thumbnail that you created.
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail!.cgImage
                }
            }
        }
    }
    
    
    func getTime() -> String {
        guard let date = dateAddedOrCreated else { return ""}
        
        return "\(Calendar.current.component(.hour, from: date)):\(Calendar.current.component(.minute, from: date))"
    }
    
    func updateInfo(strDate: String) {
        self.fileSize = Utils.sizeForLocalFilePath(filePath: filePath)
        self.dateAddedOrCreated = strDate.toDate()
    }
    
}
