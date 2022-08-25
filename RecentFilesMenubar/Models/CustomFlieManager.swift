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
    @Published var terminalString = ""
    
    var timer: Timer?

    // MARK: - PRIVATE
    private init() {
//        fakeData()
    }
    
    private func fakeData() {
//        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/monterey overview.png"))
//        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/applescript timelapse result.png"))
    }
    
    private func updateFileList(fileList: [CustomFile]) {
        DispatchQueue.main.async {
            self.recentFileList = fileList
        }
    }
    
    private func updateString(_ string: String) {
        DispatchQueue.main.async {
            self.terminalString += string
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
                if isFileTypeAllow(filePath: filePath) {
                    var newFile = CustomFile(filePath: filePath, strDate: addedTime)
                    result.append(newFile)
                }
            }
            else {
                debugPrint("Regex not matching.")
            }
        }
        
        return result
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
    
    // MARK: - PUBLIC
    func getRecent() {
        
        if timer == nil {
            print("Timer is not running. Turning on...")
            self.queryTerminal()
            self.timer = Timer()
            self.timer = Timer.scheduledTimer(withTimeInterval: Double(Constants.QUERY_SECONDS), repeats: true, block: { _ in
                self.queryTerminal()
            })
        }
        else {
            print("Timer is running. Turning off...")
            timer!.invalidate()
            timer = nil
        }
    }
    
    func queryTerminal() {
        
        terminalString = ""
        
//        let regexQuery = "kMDItemDateAdded = (.+)\\s\\+.+kMDItemFSName.+(\".+\")"
//        
//        let result = "kMDItemDateAdded = 2022-08-22 21:35:15 +0000 kMDItemFSName    = \"Intervals_7D1880EB-C352-5415-A254-5E9A2AD13225.plist\""
//
//        let regexResult = result.groups(for: regexQuery)
//        debugPrint(regexResult)
//        return
        DispatchQueue.global(qos: .userInitiated).async {
            print("This is run on a background queue")
            
            let command = Constants.TERMINAL_COMMAND
            let subResult = command.runAsCommand()
            var topResult = Array(self.getResultFromRaw(subResult).reversed())
            
            topResult = topResult.count > Constants.FILES_TO_SHOWN ? Array(topResult[0...Constants.FILES_TO_SHOWN]) : topResult
            print("From query:")
            print(topResult)

            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.updateFileList(fileList: topResult)
            }
        }
       
        return
    }
    
}


