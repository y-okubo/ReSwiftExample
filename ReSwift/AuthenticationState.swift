//
//  AuthenticationState.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation
import ReSwift

// Authentication state
struct AuthenticationState: StateType {

    var changed: Bool
    private var running: Bool
    var token: String?
    var error: Error?
    var outline: Outline

    enum Action: ReSwift.Action {
        case loginEnter()
        case loginStart(username: String, password: String)
        case loginSuccess(token: String)
        case loginFailure(error: Error)
        case logout()
    }

    enum Outline {
        case s0 // 初期状態（ログアウト状態）
        case s1 // ログイン表示状態（ログアウト状態）
        case s2 // ログイン処理状態
        case s3 // ログイン成功状態
        case s4 // ログイン失敗状態
    }

    public func loggedIn() -> Bool {
        return !(token == nil)
    }

    public static func reducer(action: ReSwift.Action, state: AuthenticationState?) -> AuthenticationState {
        var newState = state ?? AuthenticationState(changed: false, running: false, token: nil, error: nil, outline: .s0)

        // 変更済みフラグリセット
        newState.changed = false

        // 関心がないアクションは処理しない
        guard let action = action as? AuthenticationState.Action else {
            return newState
        }

        switch action {
        case .loginEnter():
            newState.changed = true
            newState.running = false
            newState.token = nil
            newState.error = nil
            newState.outline = .s1
        case .loginStart(_, _):
            newState.changed = true
            newState.running = true
            newState.token = nil
            newState.error = nil
            newState.outline = .s2
        case let .loginSuccess(token):
            newState.changed = true
            newState.running = false
            newState.token = token
            newState.error = nil
            newState.outline = .s3
        case let .loginFailure(error):
            newState.changed = true
            newState.running = false
            newState.token = nil
            newState.error = error
            newState.outline = .s4
        case .logout:
            newState.changed = true
            newState.running = false
            newState.token = nil
            newState.error = nil
            newState.outline = .s0
        }

        print("Current authentication state: \(newState.outline)")

        return newState
    }

}

