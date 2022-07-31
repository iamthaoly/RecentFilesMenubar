//
//  ContentView.swift
//  RecentFilesMenubar
//
//  Created by ly on 27/07/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
//            FileItem()
//            FileItem()
            TestGeo()
        }
        .frame(width: 300, height: 90)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TestGeo: View {
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
                        
//                    VStack() {
//                        Text("7:25")
//                    }
//                        .frame(width: geo.size.width / totalColumn * [2], alignment: .top, maxHeight: .infinity)

                }
            }
        }
}

struct FileItem: View {
    private let totalColumn = 13
    
    var body: some View {
        VStack() {
            
        }
//        VStack {
//            GeometryReader { geo in
//                HStack {
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(Color.black)
//                            .frame(width: geo.size.width / 13 * 4, height: 80)
//                        VStack(alignment: .leading) {
//                            Text("How to use this file.pdf")
//                                .font(.headline)
//                            HStack() {
//                                Image(systemName: "square.and.arrow.down")
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
//                                    .aspectRatio(contentMode: .fit)
//
//                                Text("Desktop")
//                                    .font(.body)
//                            }
//                            Text("1.6 MB")
//                        }
//                        .frame(width: geo.size.width / 13 * 7, alignment: .leading)
//                        Text("7:25")
//                            .frame(width: geo.size.width / 13 * 2, alignment: .top, maxHeight: .infinity)
//
//                    }
//            }
//        }
//        VStack {
//            HStack() {
//                RoundedRectangle(cornerRadius: 5)
//                    .fill(Color.black)
//                    .frame(width: 100, height: 80)
//                VStack(alignment: .leading) {
//                    Text("How to use this file.pdf")
//                        .font(.headline)
//                    HStack() {
//                        Image(systemName: "square.and.arrow.down")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                            .aspectRatio(contentMode: .fit)
//
//                        Text("Desktop")
//                            .font(.body)
//                    }
//                    Text("1.6 MB")
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                Text("7:25")
//                    .frame(maxHeight: .infinity, alignment: .top)
//            }
//            .padding()
//            .frame(width: 400.0, height: 200)
//            Button("Show in Finder") {
//
//            }
////            Button("Button 2") {}
////                .foregroundColor(.white)
////                .padding()
////                .background(Color.accentColor)
////                .cornerRadius(8)
//
//        }
    }
}
