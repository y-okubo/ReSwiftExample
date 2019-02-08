//
//  StatusItemMenuController.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Cocoa
import ReSwift

class StatusItemMenuController: NSObject, StoreSubscriber {

    @IBOutlet weak var mountItem: NSMenuItem!
    @IBOutlet weak var loginItem: NSMenuItem!

    let loginWindowController: NSWindowController! = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "LoginWindowController") as? NSWindowController

    func subscribe() {
        AppStore.shared.store.subscribe(self)
    }

    func unsubscribe() {
        AppStore.shared.store.unsubscribe(self)
    }

    @IBAction func mount(_ sender: Any) {
        NSLog("StatusItemMenuController: mount()")
        AppStore.shared.store.dispatch(ActionCreator.switchVolumeState())
    }

    @IBAction func login(_ sender: Any) {
        NSLog("StatusItemMenuController: login()")
        AppStore.shared.store.dispatch(ActionCreator.switchAuthenticationState())
    }

    // 状態処理
    func newState(state: AppState) {
        NSLog("StatusItemMenuController: Change state")

        guard let volumeState = state.volumeState, let authenticationState = state.authenticationState else {
            return
        }

        handleVolumeState(volumeState: volumeState)
        handleAuthenticationState(authenticationState: authenticationState)
    }

    func handleVolumeState(volumeState: VolumeState) {
        if !volumeState.changed {
            return
        }

        NSLog("⚙️ UPDATE PROCESSING MENU ⚙️")

        switch volumeState.outline {
        case .s0:
            break
        case .s1:
            DispatchQueue.main.async {
                self.mountItem.title = "マウント中..."
                self.mountItem.isEnabled = false
            }
        case .s2:
            DispatchQueue.main.async {
                self.mountItem.title = "アンマウント"
                self.mountItem.isEnabled = true
            }
        case .s3:
            NSLog("StatusItemMenuController: \(volumeState.error!.localizedDescription)")
            DispatchQueue.main.async {
                let alert: NSAlert = NSAlert()
                alert.messageText = "マウントエラー"
                alert.informativeText = "マウントに失敗しました。"
                alert.alertStyle = NSAlert.Style.critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        case .s4:
            DispatchQueue.main.async {
                self.mountItem.title = "アンマウント中..."
                self.mountItem.isEnabled = false
            }
        case .s5:
            DispatchQueue.main.async {
                self.mountItem.title = "マウント"
                self.mountItem.isEnabled = true
            }
        case .s6:
            NSLog("StatusItemMenuController: \(volumeState.error!.localizedDescription)")
            DispatchQueue.main.async {
                let alert: NSAlert = NSAlert()
                alert.messageText = "アンマウントエラー"
                alert.informativeText = "アンマウントに失敗しました。"
                alert.alertStyle = NSAlert.Style.critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }

    func handleAuthenticationState(authenticationState: AuthenticationState) {
        if !authenticationState.changed {
            return
        }

        NSLog("💥 UPDATE LOGIN MENU 💥")

        switch authenticationState.outline {
        case .s0:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログイン"
                self.mountItem.isEnabled = false
//                self.showLoginWindow() // ログアウトへの状態遷移でログインウインドウを表示させるならコメント外す
            }
        case .s1:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログイン"
                self.mountItem.isEnabled = false
                self.showLoginWindow()
            }
        case .s2:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = false
                self.loginItem.title = "ログイン中..."
                self.mountItem.isEnabled = false
            }
        case .s3:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログアウト"
                self.mountItem.isEnabled = true
            }
        case .s4:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログイン"
                self.mountItem.isEnabled = false
            }
        }
    }

    // ログインウインドウ表示
    func showLoginWindow() {
        guard let window = loginWindowController.window else {
            return
        }

        loginWindowController.showWindow(self)
        window.makeKeyAndOrderFront(self)
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)
    }

}
