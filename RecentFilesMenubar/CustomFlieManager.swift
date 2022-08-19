//
//  CustomFlieManager.swift
//  RecentFilesMenubar
//
//  Created by ly on 17/08/2022.
//

import Foundation


class CustomFileManager: ObservableObject {
    
    static var shared = CustomFileManager.init()
    
    @Published var recentFileList: [CustomFile] = []
    let MILLISECOND_TO_RELOAD = 0.5
    
    private init() {
//        recentFileList = [
//
//        ]
        fakeData()
    }
    
    private func fakeData() {
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/monterey overview.png"))
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/applescript timelapse result.png"))
    }
    
    func getRecent() {
        
    }
    
}
