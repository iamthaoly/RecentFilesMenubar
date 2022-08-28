//
//  ContentView.swift
//  RecentFilesMenubar
//
//  Created by ly on 27/07/2022.
//

import SwiftUI

struct FileListView: View {
    let backgroundColor = Color(red: 18 / 255, green: 61 / 255, blue: 75 / 255)
    let onHoverColor = Color(red: 25 / 255, green: 50 / 255, blue: 61 / 255)
    
    @State private var currentHoverId: UUID?
    @StateObject var manager = CustomFileManager.shared

    var timer = Timer()
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Files")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(.leading, 6)
            if manager.recentFileList.count == 0 || manager.queryNoResult {
                if manager.queryNoResult {
                    Text("Create or add some files today to view them here 👀")
                        .foregroundColor(.white)
                        .padding(.leading, 6)
                        .padding(.top, 6)
                }
                else if manager.recentFileList.count == 0 {
                    HStack(alignment: .center, spacing: 12.0) {
                        Circle()
                            .trim(from: 0, to: 0.8)
                            .stroke(Color.blue, lineWidth: 5)
                            .frame(width: 12, height: 12)
                            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                            .animation(Animation.default.repeatForever(autoreverses: false), value: isLoading)
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isLoading = true
                                }
                            }
                        Text("Loading...")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 6)
                    }
                    .padding(.leading, 9)
                }
            }
            VStack() {
                ScrollView {
                    ForEach(manager.recentFileList) { fileItem in
                        FileItem(isSelected: .constant(currentHoverId == fileItem.id), item: fileItem)
                            .onHover { hover in
                                currentHoverId = fileItem.id
                            }
                    }
                }
            }
            VStack() {
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                }
                .frame(alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            

        }
        .frame(maxWidth: 350)
        .padding(.top, 16.0)
        .padding(.bottom, 32.0)
        .padding(/*@START_MENU_TOKEN@*/.horizontal, 25.0/*@END_MENU_TOKEN@*/)
        .background(backgroundColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView().preferredColorScheme(.light)
    }
}

struct FileItem: View {
    private let totalColumn: CGFloat = 13.0
    private let column: [CGFloat] = [3, 7, 3]
    
    let textColor = Color(red: 115, green: 128, blue: 139)
    @Binding var isSelected: Bool
    let item: CustomFile
    let onHoverColor = Color(red: 25 / 255, green: 50 / 255, blue: 61 / 255)

    var body: some View {

//            RoundedRectangle(cornerRadius: 10)
//                .background(Color.blue)
            GeometryReader { geo in
//                RoundedRectangle(cornerRadius: 10.0)
                HStack(alignment: .top) {
                    if item.thumbnail != nil {
                        Image(item.thumbnail!, scale: NSScreen.main!.backingScaleFactor, label: Text(""))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width / totalColumn * column[0], height: 80)
                    }
                    else {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.black)
                            .frame(width: geo.size.width / totalColumn * column[0], height: 80)
                    }

                    
                    VStack(alignment: .leading, spacing: 6.0) {
                        Text(item.fileName)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        HStack(alignment: .center) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 16))
                            Text(item.parentFolder)
                        }
                        Text(item.readableFileSize)
                            .font(.system(size: 13))

                    }
                    .frame(width: geo.size.width / totalColumn * column[1], alignment: .leading)
                    VStack {
                        Text(item.getTime())
                    }
                    .frame(maxWidth: geo.size.width / totalColumn * column[2], alignment: .top)
                }
                .frame(maxHeight: .infinity)
                
//                ShowFinderButtonView(offsetByX: geo.size.width / 3 * 2, offsetByY: geo.size.height / 4 * 2)
                Button("Show in Finder") {
                    print("Click on file: " + item.filePath)
//                    NSWorkspace.shared.open(
//                        URL(
//                            fileURLWithPath: item.filePath,
//                            isDirectory: true
//                        )
//                    )
                    NSWorkspace.shared.activateFileViewerSelecting([item.url])
                }
                .buttonStyle(ShowInFinder())
                .offset(x: geo.size.width / 3 * 1.9, y: geo.size.height / 4 * 2)
                .opacity(isSelected ? 1 : 0)
                    
            }
            .frame(height: 90, alignment: .center)
            .padding(.all, 8.0)
            .foregroundColor(.gray)
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? onHoverColor: Color.clear))
            .clipped()
        
    }
}


//struct ShowFinderButtonView: View {
//    let offsetByX: CGFloat
//    let offsetByY: CGFloat
//    var body: some View {
//        Button("Show in Finder") {}
//            .buttonStyle(ShowInFinder())
//            .offset(x: offsetByX, y: offsetByY)
//    }
//}

struct ShowInFinder: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.accentColor)
            .foregroundColor(Color.white.opacity(0.8))
            .cornerRadius(20)
        
    }
}
