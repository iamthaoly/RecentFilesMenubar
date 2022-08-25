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
    var url: URL
    
    init(filePath: String) {
        self.filePath = filePath
        self.url = URL.init(fileURLWithPath: filePath)
        self.fileName = url.lastPathComponent
    }
    
    init(fileName: String, strDate: String) {
        self.fileName = fileName
        self.filePath = fileName
        self.url = URL.init(fileURLWithPath: filePath)
        self.dateAddedOrCreated = strDate.toDate()
    }
    
    func getTime() -> String {
        guard let date = dateAddedOrCreated else { return ""}
        
        return "\(Calendar.current.component(.hour, from: date)):\(Calendar.current.component(.minute, from: date))"
    }
    
}
