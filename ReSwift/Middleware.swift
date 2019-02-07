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

            switch action {
            case .loginAttempt():
                break
            case .loginProcess():
                break
            case let .loginSuccess(token):
                AppStore.shared.store.dispatch(ActionCreator.prepareMount(host: "localhost", port: 3000, mountPath: "/Users/Shared/Volume"))
            case let .loginFailure(error):
                break
            case .logout:
                AppStore.shared.store.dispatch(ActionCreator.prepareUnmount())
            }
        }
    }
}
