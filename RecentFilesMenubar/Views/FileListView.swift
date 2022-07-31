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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Files")
                .font(.system(size: 16))
            VStack() {
                FileItem()
//                    .overlay(RoundedRectangle(cornerRadius: 10).fill(onHoverColor))
                FileItem()
            }
        }
        .frame(maxWidth: 350)
        .padding(.vertical, 16.0)
        .padding(/*@START_MENU_TOKEN@*/.horizontal, 25.0/*@END_MENU_TOKEN@*/)
        .background(backgroundColor)
        //TODO:  Change to the real bg color later.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView()
    }
}

struct FileItem: View {
    private let totalColumn: CGFloat = 13.0
    private let column: [CGFloat] = [4, 7, 2]
    
    var body: some View {
            GeometryReader { geo in
                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black)
                        .frame(width: geo.size.width / totalColumn * column[0], height: 80)
                    
                    VStack(alignment: .leading, spacing: 5.0) {
                        Text("How to use this file.pdf")
                            .font(.headline)
                        HStack(alignment: .center) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 16))
                            Text("Desktop")
                        }
                        Text("1.6 MB")
                    }
                    .frame(width: geo.size.width / totalColumn * column[1], alignment: .leading)
                    VStack {
                        Text("7:24")
                           
                    }
                    .frame(maxWidth: geo.size.width / totalColumn * column[2], alignment: .top)
                }
            }
            .frame(maxHeight: 90)
        }
}
