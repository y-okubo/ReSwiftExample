//
//  LoginViewController.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Cocoa
import ReSwift

class LoginViewController: NSViewController, StoreSubscriber {

    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var messagesField: NSTextField!
    @IBOutlet weak var loginButton: NSButtonCell!

    override func viewWillAppear() {
        super.viewWillAppear()

        messagesField.stringValue = "Password is \"debug\""

        // 通知するステータスを限定している
        AppStore.shared.store.subscribe(self) { subcription in subcription
            .select { state in
                state.authenticationState
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        AppStore.shared.store.unsubscribe(self)
    }

    @IBAction func login(_ sender: Any) {
        NSLog("LoginViewController: login()")

        AppStore.shared.store.dispatch(ActionCreator.prepareLogin())
    }

    // 状態処理
    func newState(state: AuthenticationState?) {
        NSLog("LoginViewController: Change state")

        guard let authenticationState = state else {
            return
        }

        if !authenticationState.isChanged {
            return
        }

        if authenticationState.isProcessing {
            // 処理中
            DispatchQueue.main.async {
                self.messagesField.stringValue = "認証中..."
                self.loginButton.isEnabled = false
            }
            // 次状態に遷移
            AppStore.shared.store.dispatch(ActionCreator.executeLogin(username: usernameField.stringValue, password: passwordField.stringValue))
        } else {
            // 処理完了
            DispatchQueue.main.async {
                self.messagesField.stringValue = ""
                self.loginButton.isEnabled = true
            }

            if authenticationState.token != nil {
                NSLog("😁 GET TOKEN 😁")
                DispatchQueue.main.async {
                    self.view.window!.close()
                }
            }

            if authenticationState.error != nil {
                DispatchQueue.main.async {
                    self.messagesField.stringValue = "パスワードが違います"
                }
            }
        }
    }

}
