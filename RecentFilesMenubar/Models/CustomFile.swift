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
    
    // MARK: - VARIABLES
    
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
    
    // MARK: - INIT
    
    init(filePath: String, strDate: String) {
        self.filePath = filePath
        self.url = URL.init(fileURLWithPath: filePath)
        self.fileName = url.lastPathComponent
        self.dateAddedOrCreated = strDate.toDate()
        self.fileSize = Utils.sizeForLocalFilePath(filePath: filePath)
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.getThumb()
        }
    }
    
    // MARK: - PRIVATE
    
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
    
    // MARK: - PUBLIC
    
    func getTime() -> String {
        guard let date = dateAddedOrCreated else { return ""}
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return String(format: "%02d:%02d", hour, minute)
    }
    
    func updateInfo(strDate: String) {
        self.fileSize = Utils.sizeForLocalFilePath(filePath: filePath)
        self.dateAddedOrCreated = strDate.toDate()
    }
    
}
