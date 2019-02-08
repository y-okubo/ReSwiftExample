//
//  Middleware.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation
import ReSwift

// 認証成功でマウント・ログアウトでアンマウントをする（ミドルウェアで実装しなくても良い）
let middleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            guard let action = action as? AuthenticationState.Action else {
                return
            }

            guard let state = getState(), let authenticationState = state.authenticationState, let volumeState = state.volumeState else {
                return
            }

            switch action {
            case .loginEnter():
                break
            case let .loginStart(username, password):
                AppStore.shared.store.dispatch(ActionCreator.executeLogin(username: username, password: password))
            case .loginFailure(_):
                dispatch(AuthenticationState.Action.loginEnter())
            case let .loginSuccess(token):
                dispatch(VolumeState.Action.mounting(path: "/Users/Shared/Volume"))
            case .logout:
                if volumeState.mounted() {
                    dispatch(VolumeState.Action.unmounting(path: "/Users/Shared/Volume"))
                }
            }
        }
    }
}


