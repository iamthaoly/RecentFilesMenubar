//
//  AppDelegate.swift
//  RecentFilesMenubar
//
//  Created by ly on 27/08/2022.
//

import Foundation
import Cocoa
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    static private(set) var instance: AppDelegate! = nil

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        // The length can be changed
        AppDelegate.instance = self 
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(
              systemSymbolName: "hammer",
              accessibilityDescription: nil
            )
            statusButton.action = #selector(togglePopover)
        }
        
//        let maxHeight = 1000
//        let customHeight = 90 * CustomFileManager.shared.recentFileList.count + 300
//        let minHeight =  min(maxHeight, customHeight)
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 400, height: 200)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: FileListView())
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            print("Toggle popover")
            if popover.isShown {
                print("Close status bar.")
                self.popover.performClose(nil)
//                CustomFileManager.shared.getRecent()
            }
            else {
                CustomFileManager.shared.getRecent()

                print("Show status bar?")
                let maxHeight = Constants.MAX_WINDOW_HEIGHT
                let customHeight: Double = Constants.LIST_ITEM_HEIGHT * Double(CustomFileManager.shared.recentFileList.count) + 200
                let minHeight =  min(maxHeight, customHeight)
                popover.contentSize = NSSize(width: 400, height: minHeight)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func updatePopoverSize(width: Double = 400, height: Double = 200) {
        if let button = statusItem.button {
            popover.performClose(nil)
            
            popover.contentSize = NSSize(width: width, height: height)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
    
}
