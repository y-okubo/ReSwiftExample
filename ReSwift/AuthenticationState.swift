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

    var isChanged: Bool
    var isProcessing: Bool
    var token: String?
    var error: Error?

    enum Action: ReSwift.Action {
        case entered()
        case loggingIn()
        case loginSuccess(token: String)
        case loginFailure(error: Error)
        case logout()
    }

    public static func reducer(action: ReSwift.Action, state: AuthenticationState?) -> AuthenticationState {
        var newState = state ?? AuthenticationState(isChanged: false, isProcessing: false, token: nil, error: nil)

        // 変更済みフラグリセット
        newState.isChanged = false

        // 関心がないアクションは処理しない
        guard let action = action as? AuthenticationState.Action else {
            return newState
        }

        switch action {
        case .entered():
            newState.isChanged = true
        case .loggingIn():
            newState.isChanged = true
            newState.isProcessing = true
            newState.token = nil
            newState.error = nil
        case let .loginSuccess(token):
            newState.isChanged = true
            newState.isProcessing = false
            newState.token = token
            newState.error = nil
        case let .loginFailure(error):
            newState.isChanged = true
            newState.isProcessing = false
            newState.token = nil
            newState.error = error
        case .logout:
            newState.isChanged = true
            newState.isProcessing = false
            newState.token = nil
            newState.error = nil
        }

        return newState
    }

}

