//
//  RecentFilesMenubarApp.swift
//  RecentFilesMenubar
//
//  Created by ly on 27/07/2022.
//

import SwiftUI

@main
struct RecentFilesMenubarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            FileListView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        // The length can be changed
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(
              systemSymbolName: "hammer",
              accessibilityDescription: nil
            )
            statusButton.action = #selector(togglePopover)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 400, height: 300)
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
                print("Show status bar?")
                CustomFileManager.shared.getRecent()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
