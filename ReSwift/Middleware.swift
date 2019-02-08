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

            var state = getState()
            print(state)

            switch action {
            case .loginAttempt(), .loginProcess(), .loginFailure(_):
                break
            case let .loginSuccess(token):
                dispatch(VolumeState.Action.mounting(path: "/Users/Shared/Volume"))
            case .logout:
                dispatch(VolumeState.Action.unmounting(path: "/Users/Shared/Volume"))
            }
        }
    }
}
