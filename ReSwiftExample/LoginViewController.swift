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

        AppStore.shared.store.dispatch(ActionCreator.startLogin(username: usernameField.stringValue, password: passwordField.stringValue))
    }

    // 状態処理
    func newState(state: AuthenticationState?) {
        NSLog("LoginViewController: Change state")

        guard let authenticationState = state else {
            return
        }

        if !authenticationState.changed {
            return
        }

        switch authenticationState.outline {
        case .s0, .s1:
            DispatchQueue.main.async {
                self.usernameField.isEnabled = true
                self.passwordField.isEnabled = true
                self.messagesField.stringValue = "Password is \"debug\""
                self.loginButton.isEnabled = true
            }
        case .s2:
            DispatchQueue.main.async {
                self.usernameField.isEnabled = false
                self.passwordField.isEnabled = false
                self.messagesField.stringValue = "認証中..."
                self.loginButton.isEnabled = false
            }
        case .s3:
            DispatchQueue.main.async {
                self.usernameField.isEnabled = false
                self.passwordField.isEnabled = false
                self.messagesField.stringValue = ""
                self.loginButton.isEnabled = true
                self.view.window!.close()
            }
        case .s4:
            DispatchQueue.main.async {
                self.usernameField.isEnabled = true
                self.passwordField.isEnabled = true
                self.messagesField.stringValue = "パスワードが違います"
                self.loginButton.isEnabled = true
            }
        }

    }

}
