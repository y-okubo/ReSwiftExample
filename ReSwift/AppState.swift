//
//  AppState.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation
import ReSwift

class AppStore: NSObject {
    let store = Store<AppState>(
        reducer: AppState.reducer,
        state: nil,
        middleware: []
    )

    static let shared: AppStore = AppStore()
    private override init() {}
}

struct AppState: StateType {

    // 認証状態
    var authenticationState: AuthenticationState?
    // マウント状態
    var volumeState: VolumeState?

    public static func reducer(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()

        state.authenticationState = AuthenticationState.reducer(action: action, state: state.authenticationState)
        state.volumeState = VolumeState.reducer(action: action, state: state.volumeState)

        return state
    }

}

