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
        AppStore.shared.store.dispatch(ActionCreator.switchVolumeState(host: "localhost", port: 3000, mountPath: "/Users/Shared/Volume"))
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
        if !volumeState.isChanged {
            return
        }

        // マウント状態判定
        if let type = volumeState.type {
            NSLog("⚙️ VOLUME PROCESSING ... ⚙️")
            // 処理中の表示処理
            switch type {
            case .mount:
                DispatchQueue.main.async {
                    self.mountItem.title = "マウント中..."
                    self.mountItem.isEnabled = false
                }
                // 次状態に遷移
                AppStore.shared.store.dispatch(ActionCreator.executeMount(host: "localhost", port: 3000, mountPath: "/Users/Shared/Volume"))
            case .unmount:
                DispatchQueue.main.async {
                    self.mountItem.title = "アンマウント中..."
                    self.mountItem.isEnabled = false
                }
                // 次状態に遷移
                AppStore.shared.store.dispatch(ActionCreator.executeUnmount())
            }
        } else {
            NSLog("🙆‍♂️ VOLUME PROCESS FINISH 🙆‍♂️")
            // 処理完了の表示処理
            if let _ = volumeState.path {
                DispatchQueue.main.async {
                    self.mountItem.title = "アンマウント"
                    self.mountItem.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.mountItem.title = "マウント"
                    self.mountItem.isEnabled = true
                }
            }

            // エラーがある場合の表示処理
            if let error = volumeState.error {
                switch error {
                case let .mount(error):
                    NSLog("StatusItemMenuController: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let alert: NSAlert = NSAlert()
                        alert.messageText = "マウントエラー"
                        alert.informativeText = "マウントに失敗しました。"
                        alert.alertStyle = NSAlert.Style.critical
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                case let .unmount(error):
                    NSLog("StatusItemMenuController: \(error.localizedDescription)")
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
            }
            AppStore.shared.store.dispatch(ActionCreator.attempLogin())
        case .s1:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = false
                self.loginItem.title = "ログイン"
                self.showLoginWindow()
            }
        case .s2:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = false
                self.loginItem.title = "ログイン中..."
            }
        case .s3:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログアウト"
            }
        case .s4:
            DispatchQueue.main.async {
                self.loginItem.isEnabled = true
                self.loginItem.title = "ログイン"
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
