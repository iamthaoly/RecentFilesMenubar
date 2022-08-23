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
    let MILLISECOND_TO_RELOAD = 0.5
    let MAX_RESULTS = 10
    
    var timer: Timer?
    let REGEX_QUERY = "kMDItemDateAdded = (.+)\\s\\+.+kMDItemFSName.+(\".+\")"

    // MARK: - PRIVATE
    private init() {
        fakeData()
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
        
//        let result = "kMDItemDateAdded = 2022-08-22 21:35:15 +0000 kMDItemFSName    = \"Intervals_7D1880EB-C352-5415-A254-5E9A2AD13225.plist\""
        var result = [CustomFile]()
        
        for aLine in lines {
            let regexResult = aLine.groups(for: REGEX_QUERY)
            if regexResult.count > 0 && regexResult[0].count > 0{
                let group = regexResult[0]
                let addedTime = group[1]
                let fileName = group[2]
                if isFileTypeAllow(fileName: fileName) {
                    let newFile = CustomFile(fileName: fileName, strDate: addedTime)
                    result.append(newFile)
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
        for extensionType in Utils.extensions {
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
            for extensionType in Utils.extensions {
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
            self.timer = Timer()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.queryTerminal()
            })
        }
        else {
//            print("Timer is already running!")
            timer!.invalidate()
            timer = nil
        }
    }
    
    func queryTerminal() {
        // mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-3) && kMDItemFSName = "*.py"'
        // mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-3) && kMDItemFSName = "*.png"' | head -4
        
        terminalString = ""
//        let url = URL(fileURLWithPath: "brew_script.sh", relativeTo: Bundle.main.resourceURL)
//        let command = "mdfind -live -onlyin ~ 'kMDItemDateAdded >= $time.today(-1)'"
        // mdls -name kMDItemFSName -name kMDItemDateAdded -raw **/* | xargs -0 -I {} echo {} | sed 'N;s/\n/ /' | sort
        // mdls -name kMDItemFSName -name kMDItemDateAdded -raw /Users/ly/* | xargs -0 -I {} echo {} | sed 'N;s/\n/ /' | sort
        // mdls -name kMDItemFSName -name kMDItemDateAdded -raw .*/* | xargs -0 -I {} echo {} | sed 'N;s/\n/ /' | sort
        
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
        
        let cm = """
        mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today OR kMDItemFSCreationDate >= $time.today' | \
        xargs  -I abc echo abc  | \
        xargs -I {} mdls -name kMDItemFSName -name kMDItemDateAdded {} | \
        sed 'N;s/\n/ /' | \
        sort
        """
        
        // How to echo the path???
        let cm2 = """
        mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today OR kMDItemFSCreationDate >= $time.today' | \
        xargs -I abc echo abc  | \
        xargs -I {} echo  "\"{}\"" | \
        xargs -I _v sh -c "mdls -name kMDItemFSName -name kMDItemDateAdded _v; echo "${_v}""

        
        xargs mdls -name kMDItemFSName -name kMDItemDateAdded | \
        xargs -I _v sh -c "echo _v; mdls _v"
        
        sed 'N;s/\n/ /' | \
        sort
        """
        
        let command = cm
        let subResult = command.runAsCommand()
        var topResult = Array(self.getResultFromRaw(subResult))
//        topResult = self.filterAllowFileType(files: topResult)
        
        topResult = topResult.count > self.MAX_RESULTS ? Array(topResult[0...9]) : topResult
        print("From query:")
        print(topResult)
        
        return
        
        print("Command: ")
        print(command)
        let task = Process()
        updateString(command + "\n")


        task.launchPath = "/bin/sh"
        task.arguments = ["-c", command]
//        task.arguments = ["-c", "echo 1 ; sleep 1 ; echo 2 ; sleep 1 ; echo 3 ; sleep 1 ; echo 4"]

        let myPipe = Pipe()
        task.standardOutput = myPipe
        let outHandle = myPipe.fileHandleForReading
        
//        let errPipe = Pipe()
//        task.standardError = errPipe
//        let errHandle = errPipe.fileHandleForReading
        
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding(rawValue: NSUTF8StringEncoding) ) {
                if pipe.availableData.isEmpty  {
                    print("EOF stdout: This command is done!")
                    myPipe.fileHandleForReading.readabilityHandler = nil
                    DispatchQueue.main.async {
//                        self.isBrewDone = true
                    }
//                    self.runInitScript()
                }
                else {
                    if line != "" && line.count > 0 {
//                        print("New output stdout: \(line)")
                        if (line.contains("Query update:")) {
                            self.updateString(line)
                            let subCommand = "mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-3) OR kMDItemFSCreationDate >= $time.today(-3)'"
                            let subResult = subCommand.runAsCommand()
                            var topResult = Array(self.getResultFromRaw(subResult).reversed())
//                            topResult = self.filterAllowFileType(files: topResult)
                            topResult = topResult.count > self.MAX_RESULTS ? Array(topResult[0...9]) : topResult
                            print("From query update:")
                            print(topResult)
                        }
                        else {
                            self.updateString(line)
                            var topResult = Array(self.getResultFromRaw(line).reversed())
//                            topResult = self.filterAllowFileType(files: topResult)
                            topResult = topResult.count > self.MAX_RESULTS ? Array(topResult[0...9]) : topResult
                            print("Normal:")
                            print(topResult)
                            
                        }
//
                    }
                }

            }
        }
//        errHandle.readabilityHandler = { pipe in
//            if let line = String(data: pipe.availableData, encoding: String.Encoding(rawValue: NSUTF8StringEncoding) ) {
//                if pipe.availableData.isEmpty  {
//                    print("EOF stderr: This command is done!")
//                    myPipe.fileHandleForReading.readabilityHandler = nil
//                    DispatchQueue.main.async {
////                        self.isBrewDone = true
//                    }
////                    self.runInitScript()
//                }
//                else {
//                    if line != "" && line.count > 0 {
//                        print("New output stderr: \(line)")
//                        if (line.contains("Query update:")) {
//                            self.updateString(line)
//                            let subCommand = "mdfind -onlyin ~ 'kMDItemDateAdded >= $time.today(-1)'"
//                            let subResult = subCommand.runAsCommand()
//                            print(subResult)
//                        }
//                        else {
//                            self.updateString(line)
//                        }
////
//                    }
//                }
//
//            }
//        }

        task.launch()
        task.waitUntilExit()
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
//    func getDateFromString(_ string: String) -> Date{
//
//    }
    
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
