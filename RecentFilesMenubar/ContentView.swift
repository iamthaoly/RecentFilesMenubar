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
            FileItem()
            FileItem()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FileItem: View {
    var body: some View {
    
        VStack {
            HStack() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.black)
                    .frame(width: 100, height: 60)
                VStack(alignment: .leading) {
                    Text("How to use this file.pdf")
                        .font(.headline)
                    HStack() {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .aspectRatio(contentMode: .fit)
                        
                        Text("Desktop")
                            .font(.body)
                    }
                    Text("1.6 MB")
                }
                .frame(maxWidth: .infinity)
                Text("7:25")
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding()
            .frame(width: 300.0, height: 150)
            Button("Show in Finder") {
                
            }
        }
    }
}
