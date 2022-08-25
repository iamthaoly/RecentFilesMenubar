//
//  CustomFile.swift
//  RecentFilesMenubar
//
//  Created by ly on 17/08/2022.
//

import Foundation

struct CustomFile: Identifiable {
    let id = UUID()
    var fileName: String = ""
    var filePath: String = ""
    var thumbnail: String = ""
    var dateAddedOrCreated: Date?
    var fileSize: UInt64?
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

    }
    
//    init(fileName: String, strDate: String) {
//        self.fileName = fileName
//        self.filePath = fileName
//        self.url = URL.init(fileURLWithPath: filePath)
//        self.dateAddedOrCreated = strDate.toDate()
//    }
    
    
    func getTime() -> String {
        guard let date = dateAddedOrCreated else { return ""}
        
        return "\(Calendar.current.component(.hour, from: date)):\(Calendar.current.component(.minute, from: date))"
    }
    
}
