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
    var timer: Timer?
    private var isQuerying: Bool = false
    @Published var queryNoResult = false
    
    // MARK: - PRIVATE
    private init() {
        //        fakeData()
        if checkSpotlightEnabled() == false{
            turnOnSpotlightIndexing()
        }
    }

    
    private func fakeData() {
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/monterey overview.png", strDate: "123"))
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/applescript timelapse result.png", strDate: "123"))
    }
    
    private func updateFileList(fileList: [CustomFile]) {
        DispatchQueue.main.async {
            self.recentFileList = []
            self.recentFileList = fileList
        }
    }
    
    private func getResultFromRaw(_ text: String) -> [CustomFile] {
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        var result = [CustomFile]()
        
        for aLine in lines {
            let regexResult = aLine.groups(for: Constants.REGEX_QUERY)
            if regexResult.count > 0 && regexResult[0].count > 0{
                let group = regexResult[0]
                let addedTime = group[1]
                let filePath = group[2]
                
                if filePath == "{}" {
                    continue
                }
                // If we can find the file in the list (add index >= 0) -> add item[index] to the current list.
                let added = isThisPathAdded(filePath)
                if (added >= 0) {
                    recentFileList[added].updateInfo(strDate: addedTime)
                    result.append(recentFileList[added])
                }
                else {
                    let libraryPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library").path
                    let newFile = CustomFile(filePath: filePath, strDate: addedTime)
                    result.append(newFile)
//                    if isFileTypeAllow(filePath: filePath) && filePath.hasPrefix(libraryPath) == false {
//                        let newFile = CustomFile(filePath: filePath, strDate: addedTime)
//                        result.append(newFile)
//                    }
                }
            }
            else {
                debugPrint("Regex not matching.")
            }
        }
        
        return result
    }
    
    
    private func isThisPathAdded(_ path: String) -> Int {
        for i in 0..<recentFileList.count {
            if (recentFileList[i].filePath == path) {
                return i
            }
        }
        return -1
    }
    
    private func isFileTypeAllow(filePath: String) -> Bool {
        let fileExtension = filePath.getExtension()
        for extensionType in Constants.extensions {
            if extensionType.value.contains(fileExtension) {
                return true
            }
        }
        return false
    }
    
    private func filterAllowFileType(files: [String]) -> [String] {
        var result: [String] = []
        
        for fileItem in files {
            let url = URL.init(fileURLWithPath: fileItem)
            let fileExtension = url.pathExtension.lowercased()
            for extensionType in Constants.extensions {
                if extensionType.value.contains(fileExtension) {
                    result.append(fileItem)
                    break
                }
            }
        }
        
        return result
    }
    
    private func isSameList(list: [CustomFile]) -> Bool {
        if list.count != recentFileList.count {
            return false
        }
        for i in 0..<list.count {
            if list[i].filePath != recentFileList[i].filePath {
                return false
            }
        }
        return true
    }
    // MARK: - PUBLIC
    
    func checkSpotlightEnabled() -> Bool {
        let command = Constants.CHECK_IF_SPOTLIGHT_ENABLED
        
        let res = command.runAsCommand()
        debugPrint(res)
        if res.contains("enabled") {
            return true
        }
        return false
    }
    
    func turnOnSpotlightIndexing() {
        let command = Constants.ENABLE_SPOTLIGHT
        let res = command.runInsideApplescript(script: command, asAdmin: true)
        debugPrint(res)
        
    }
    
    func getRecent() {
        if timer == nil {
            print("Timer is not running. Turning on...")
            self.queryTerminal()
            self.timer = Timer()
            self.timer = Timer.scheduledTimer(withTimeInterval: Double(Constants.QUERY_SECONDS), repeats: true, block: { _ in
                self.queryTerminal()
            })
        }
//        else {
//            print("Timer is running. Turning off...")
//            timer!.invalidate()
//            timer = nil
//        }
    }
    
    func queryTerminal() {
        
        
        //        let regexQuery = "kMDItemDateAdded = (.+)\\s\\+.+kMDItemFSName.+(\".+\")"
        //
        //        let result = "kMDItemDateAdded = 2022-08-22 21:35:15 +0000 kMDItemFSName    = \"Intervals_7D1880EB-C352-5415-A254-5E9A2AD13225.plist\""
        if isQuerying == true {
            return
        }
        isQuerying = true
        DispatchQueue.global(qos: .userInitiated).async {
            print("This is run on a background queue")
            
            let command = Constants.TERMINAL_COMMAND
            let subResult = command.runAsCommand()
            var topResult = Array(self.getResultFromRaw(subResult).reversed())
            
            topResult = topResult.count > Constants.FILES_TO_SHOWN ? Array(topResult[0...Constants.FILES_TO_SHOWN]) : topResult
            print("From query:")
            debugPrint("manager: files from query::")
            debugPrint(topResult)
//            topResult = []
//            print(topResult)
            
            
            DispatchQueue.main.async {
                self.queryNoResult = (topResult.count == 0)
                print("This is run on the main queue, after the previous code in outer block")
                if self.isSameList(list: topResult) == false{
                    debugPrint("manager: new files. update view")
                    self.updateFileList(fileList: topResult)
                }
                else {
                    debugPrint("manager: no new files. not update view")
                }
                self.isQuerying = false
                
            }
        }
        
    }
    
}


