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
    var filePath: String
    var thumbnail: String = ""
    
    private var url: URL
    
    init(filePath: String) {
        self.filePath = filePath
        self.url = URL.init(fileURLWithPath: filePath)
        self.fileName = url.lastPathComponent
    }
}
