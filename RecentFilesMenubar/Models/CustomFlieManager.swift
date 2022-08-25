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
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/monterey overview.png"))
        recentFileList.append(CustomFile(filePath: "/Users/ly/Desktop/applescript timelapse result.png"))
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
//        kMDItemDateAdded = 2022-08-22 08:09:36 +0000 kMDItemFSName    = "com.apple.TextEdit.plist"
        
//        let result = "kMDItemDateAdded = 2022-08-22 21:35:15 +0000 kMDItemFSName    = \"Intervals_7D1880EB-C352-5415-A254-5E9A2AD13225.plist\"  kMDItemPhysicalSize = 4096"
        var result = [CustomFile]()
        
        for aLine in lines {
            let regexResult = aLine.groups(for: Constants.REGEX_QUERY)
            if regexResult.count > 0 && regexResult[0].count > 0{
                let group = regexResult[0]
                let addedTime = group[1]
                let fileName = group[2].replacingOccurrences(of: "\"", with: "")
//                let fileSize = group[3].contains("null") ? "0" : group[3]
                if isFileTypeAllow(fileName: fileName) {
                    var newFile = CustomFile(fileName: fileName, strDate: addedTime)
//                    newFile.fileSize = UInt64(fileSize)
                    result.append(newFile)
//                    print(newFile.dateAddedOrCreated)
                }
            }
            else {
                debugPrint("Regex not matching.")
            }
        }
        
        return result
    }
    
    private func isFileTypeAllow(fileName: String) -> Bool {
        let url = URL.init(fileURLWithPath: fileName)
        let fileExtension = url.pathExtension.lowercased()
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
        // mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-3) && kMDItemFSName = "*.py"'
        // mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-3) && kMDItemFSName = "*.png"' | head -4
        
        terminalString = ""
        
        // mdfind -onlyin ~/Desktop 'kMDItemDateAdded >= $time.today(-3)' | \
//        xargs  -I abc echo abc  | \
//        xargs -I {} mdls -name kMDItemFSName -name kMDItemDateAdded {} | \
//        sed 'N;s/\n/ /' | \
//        sort
        
//        let regexQuery = "kMDItemDateAdded = (.+)\\s\\+.+kMDItemFSName.+(\".+\")"
//        
//        let result = "kMDItemDateAdded = 2022-08-22 21:35:15 +0000 kMDItemFSName    = \"Intervals_7D1880EB-C352-5415-A254-5E9A2AD13225.plist\""
//
//        let regexResult = result.groups(for: regexQuery)
//        debugPrint(regexResult)
//        return
        DispatchQueue.global(qos: .userInitiated).async {
            print("This is run on a background queue")
            let cm2 = #"mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today OR kMDItemFSCreationDate >= $time.today' | xargs  -I abc echo abc  | xargs -I {} mdls -name kMDItemFSName -name kMDItemDateAdded {} | sed 'N;s/\n/ /' | sort"#
//            N;s/\n/ /
            
            let command = Constants.TERMINAL_COMMAND
            let subResult = command.runAsCommand()
            var topResult = Array(self.getResultFromRaw(subResult).reversed())
    //        topResult = self.filterAllowFileType(files: topResult)
            
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

extension String {
    func runAsCommand() -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        task.waitUntilExit()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            return "--- Error running command - Unable to initialize string from file data ---"
        }
    }
}

extension String {
    // current: 2022-08-23 04:59:15
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> Date?{

        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
//        dateFormatter.locale = Locale(identifier: "fa-IR")
//        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+00:00")//Add this
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from: self)

        return date

    }
    
    // NOT WORKING :(
//    var unescaped: String {
//        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\"]
//        var current = self
//        for entity in entities {
//            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
//            let description = String(descriptionCharacters)
//            current = current.replacingOccurrences(of: description, with: entity)
//        }
//        return current
//    }
//
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
