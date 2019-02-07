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

    // ログイン or ログアウト
    static func switchAuthenticationState() -> Store<AppState>.ActionCreator {
        return { (state, store) in
            if let authenticationState = state.authenticationState, let _ = authenticationState.token {
                return AuthenticationState.Action.logout()
            } else {
                return AuthenticationState.Action.loginAttempt()
            }
        }
    }

    // マウント or アンマウント
    static func switchVolumeState(host: String, port: Int32, mountPath: String) -> Store<AppState>.ActionCreator {
        return { (state, store) in
            if let authenticationState = state.authenticationState, let _ = authenticationState.token {
                if let volumeState = state.volumeState, let path = volumeState.path {
                    return VolumeState.Action.unmounting(path: path)
                } else {
                    return VolumeState.Action.mounting(path: mountPath)
                }
            } else {
                return AuthenticationState.Action.loginAttempt()
            }
        }
    }

    // ログイン準備
    static func prepareLogin() -> Store<AppState>.ActionCreator {
        return { (state, store) in
            // 既にログイン済ならな何もしない
            if let authenticationState = state.authenticationState, let _ = authenticationState.token {
                return nil
            } else {
                return AuthenticationState.Action.loginProcess()
            }
        }
    }

    // ログイン実行
    static func executeLogin(username: String, password: String) -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            DispatchQueue.global(qos: .default).async {
                callback { _, _ in requestLogin(username: username, password: password) }
            }
        }
    }

    // マウント準備
    static func prepareMount(host: String, port: Int32, mountPath: String) -> Store<AppState>.ActionCreator {
        return { (state, store) in
            // 未ログインだとエラー
            if let authenticationState = state.authenticationState, let _ = authenticationState.token {
                return VolumeState.Action.mounting(path: mountPath)
            } else {
                return VolumeState.Action.mountFailure(error: VolumeState.LastActionError.mount(error: MountError.unauthorized))
            }
        }
    }

    // マウント実行
    static func executeMount(host: String, port: Int32, mountPath: String) -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            if let authenticationState = state.authenticationState, let token = authenticationState.token {
                DispatchQueue.global(qos: .default).async {
                    callback { _, _ in requestMount(host: host, port: port, token: token, mountPath: mountPath) }
                }
            } else {
                callback { _, _ in VolumeState.Action.mountFailure(error: VolumeState.LastActionError.mount(error: MountError.unauthorized)) }
            }
        }
    }

    // アンマウント準備
    static func prepareUnmount() -> Store<AppState>.ActionCreator {
        return { (state, store) in
            // 既にアンマウント済なら何もしない
            if let volumeState = state.volumeState, let path = volumeState.path {
                return VolumeState.Action.unmounting(path: path)
            } else {
                return nil
            }
        }
    }

    // アンマウント実行
    static func executeUnmount() -> Store<AppState>.AsyncActionCreator {
        return { (state, store, callback) in
            // 既にアンマウント済なら何もしない
            if let volumeState = state.volumeState, let path = volumeState.path {
                DispatchQueue.global(qos: .default).async {
                    callback { _, _ in requestUnmount(mountPath: path) }
                }
            }
        }
    }

    // 実際のマウント処理
    static private func requestMount(host: String, port: Int32, token: String, mountPath: String) -> VolumeState.Action {
        NSLog("Mounting...")
        Thread.sleep(forTimeInterval: 3.0)

        // 適度に成功・失敗しそうな頻度を再現
        if Int.random(in: 1 ... 100) % 1 == 0 {
            NSLog("Mount success")
            return VolumeState.Action.mountSuccess(path: mountPath)
        } else {
            NSLog("Mount failure")
            return VolumeState.Action.mountFailure(error: VolumeState.LastActionError.mount(error: MountError.unknown))
        }
    }

    // 実際のアンマウント処理
    static private func requestUnmount(mountPath: String) -> VolumeState.Action {
        NSLog("Unmounting...")
        Thread.sleep(forTimeInterval: 3.0)

        // 適度に成功・失敗しそうな頻度を再現
        if Int.random(in: 1 ... 100) % 1 == 0 {
            NSLog("Unmount success")
            return VolumeState.Action.unmountSuccess(path: mountPath)
        } else {
            NSLog("Unmount failure")
            return VolumeState.Action.unmountFailure(error: VolumeState.LastActionError.unmount(error: MountError.unknown))
        }
    }

    // 実際のログイン処理
    static private func requestLogin(username: String, password: String) -> AuthenticationState.Action {
        let semaphore = DispatchSemaphore(value: 0)
        var action: AuthenticationState.Action? = nil
        let task = URLSession.shared.dataTask(with: URL(string: "https://httpbin.org/status/200")!) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                action = AuthenticationState.Action.loginFailure(error: ServerError.unknown)
                semaphore.signal()
                return
            }

            // 関数渡してあげるから適切な引数を渡して呼び出してな
            if response.statusCode != 200 || password != "debug"{
                NSLog("Login failure")
                action = AuthenticationState.Action.loginFailure(error: ServerError.notFound)
            } else if let error = error {
                NSLog("Login failure")
                action = AuthenticationState.Action.loginFailure(error: error)
            } else {
                NSLog("Login success")
                action = AuthenticationState.Action.loginSuccess(token: "THIS_IS_TOKEN")
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        return action!
    }

}
