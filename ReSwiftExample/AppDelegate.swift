//
//  AppDelegate.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusItemMenu: NSMenu!
    @IBOutlet weak var statusItemMenuController: StatusItemMenuController!
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem.button!.title = "ReSwift"
        self.statusItem.menu = statusItemMenu
        statusItemMenuController.subscribe()
        // 起動時にキーチェーンから情報を読み出してログインさせることを想定
        AppStore.shared.store.dispatch(ActionCreator.executeLogin(username: "debug", password: "debug"))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        statusItemMenuController.unsubscribe()
    }

}

