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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Files")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(.leading, 6)
            VStack() {
                if manager.recentFileList.count == 0 {
                    Text("Add or create a file to view it here.")
                }

                ScrollView {
                    ForEach(manager.recentFileList) { fileItem in
                        FileItem(isSelected: .constant(currentHoverId == fileItem.id), item: fileItem)
                            .onHover { hover in
                                currentHoverId = fileItem.id
                            }
                    }
                }
//                FileItem(isSelected: .constant(currentHoverIndex == 0))
//                    .onHover { hover in
//                        currentHoverIndex = 0
//                    }
//                    .background(RoundedRectangle(cornerRadius: 10).fill(currentHoverIndex == 0 ? onHoverColor: Color.clear))
//                    .clipped()
//                FileItem(isSelected: .constant(currentHoverIndex == 1))
//                    .onHover { hover in
//                        currentHoverIndex = 1
//                    }
//                    .background(RoundedRectangle(cornerRadius: 10).fill(currentHoverIndex == 1 ? onHoverColor: Color.clear))
//                    .clipped()
//                Button("TEST") {
//                    manager.getRecent()
//                }
            }

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
    private let column: [CGFloat] = [4, 7, 2]
    
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
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black)
                        .frame(width: geo.size.width / totalColumn * column[0], height: 80)
                    
                    VStack(alignment: .leading, spacing: 6.0) {
                        Text(item.fileName)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        HStack(alignment: .center) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 16))
                            Text("Folder")
                        }
                        Text("1.6 MB")
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
                .offset(x: geo.size.width / 3 * 2, y: geo.size.height / 4 * 2)
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
            .padding(8)
            .background(Color.blue)
            .foregroundColor(Color.white.opacity(0.8))
            .cornerRadius(14)
        
    }
}
