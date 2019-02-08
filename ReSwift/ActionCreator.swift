//
//  Action.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation
import ReSwift

struct ActionCreator {

    static let path = "/Users/Shared/Volume"
    static let host = "localhost"
    static let port: Int32 = 3000

    // ログイン or ログアウト
    static func switchAuthenticationState() -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            guard let authenticationState = state.authenticationState, let volumeState = state.volumeState else {
                return callback { _, _ in nil }
            }

            if authenticationState.loggedIn {
                // ログインしているならログアウト
                store.dispatch(AuthenticationState.Action.logout())
                if !volumeState.mounted {
                    // マウントしていないなら何もしない
                    return callback { _, _ in AuthenticationState.Action.logout() }
                }

                // 非同期でアンマウント
                DispatchQueue.global(qos: .default).async {
                    store.dispatch(VolumeState.Action.unmounting(path: self.path))
                    if requestUnmount(path: self.path) {
                        callback { _, _ in VolumeState.Action.unmountSuccess(path: self.path) }
                    } else {
                        callback { _, _ in VolumeState.Action.unmountFailure(error: MountError.unauthorized) }
                    }
                }
            } else {
                // ログインしていないなら
                callback { _, _ in AuthenticationState.Action.loginEnter() }
            }
        }
    }

    // マウント or アンマウント
    static func switchVolumeState() -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            guard let authenticationState = state.authenticationState, let volumeState = state.volumeState else {
                return callback { _, _ in nil }
            }

            guard let token = authenticationState.token else {
                return callback { _, _ in nil }
            }

            if !authenticationState.loggedIn {
                // ログインをしていない
                return callback { _, _ in AuthenticationState.Action.loginEnter() }
            }

            if volumeState.mounted {
                // マウント中ならアンマウント
                store.dispatch(VolumeState.Action.unmounting(path: path))
                DispatchQueue.global(qos: .default).async {
                    if requestUnmount(path: path) {
                        callback { _, _ in VolumeState.Action.unmountSuccess(path: path) }
                    } else {
                        callback { _, _ in VolumeState.Action.unmountFailure(error: MountError.unauthorized) }
                    }
                }
            } else {
                // アンマウント中ならマウント
                store.dispatch(VolumeState.Action.mounting(path: path))
                DispatchQueue.global(qos: .default).async {
                    if requestMount(host: self.host, port: self.port, token: token, path: path) {
                        callback { _, _ in VolumeState.Action.mountSuccess(path: path) }
                    } else {
                        callback { _, _ in VolumeState.Action.mountFailure(error: MountError.unauthorized) }
                    }
                }
            }
        }
    }

    // ログイン実行
    static func startLogin(username: String, password: String) -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            store.dispatch(AuthenticationState.Action.loginStart(username: username, password: password))
            DispatchQueue.global(qos: .default).async {
                requestLogin(username: username, password: password, callback: { token, error in
                    if let error = error {
                        callback { _, _ in AuthenticationState.Action.loginFailure(error: error) }
                    } else {
                        store.dispatch(AuthenticationState.Action.loginSuccess(token: token))
                        store.dispatch(VolumeState.Action.mounting(path: self.path))
                        if requestMount(host: self.host, port: self.port, token: token, path: self.path) {
                            callback { _, _ in VolumeState.Action.mountSuccess(path: self.path) }
                        } else {
                            callback { _, _ in VolumeState.Action.mountFailure(error: MountError.unauthorized) }
                        }
                    }
                })
            }
        }
    }

    // 実際のマウント処理
    static private func requestMount(host: String, port: Int32, token: String, path: String) -> Bool {
        NSLog("Mounting...")
        Thread.sleep(forTimeInterval: 3.0)

        // 適度に成功・失敗しそうな頻度を再現
        if Int.random(in: 1 ... 100) % 1 == 0 {
            NSLog("Mount success")
            return true
        } else {
            NSLog("Mount failure")
            return false
        }
    }

    // 実際のアンマウント処理
    static private func requestUnmount(path: String) -> Bool {
        NSLog("Unmounting...")
        Thread.sleep(forTimeInterval: 3.0)

        // 適度に成功・失敗しそうな頻度を再現
        if Int.random(in: 1 ... 100) % 1 == 0 {
            NSLog("Unmount success")
            return true
        } else {
            NSLog("Unmount failure")
            return false
        }
    }

    // 実際のログイン処理
    static private func requestLogin(username: String, password: String, callback: @escaping((String, Error?) -> Void)) {
        Thread.sleep(forTimeInterval: 2.0)
        let task = URLSession.shared.dataTask(with: URL(string: "https://httpbin.org/status/200")!) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                return
            }

            // 関数渡してあげるから適切な引数を渡して呼び出してな
            if response.statusCode != 200 || password != "debug"{
                NSLog("Login failure")
                callback("", ServerError.notFound)
            } else if let error = error {
                NSLog("Login failure")
                callback("", error)
            } else {
                NSLog("Login success")
                callback("THIS_IS_TOKEN", nil)
            }
        }
        task.resume()
    }

}
