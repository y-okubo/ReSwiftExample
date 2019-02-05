//
//  VolumeState.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/5/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation
import ReSwift

// Volume state
struct VolumeState: StateType {

    enum Action: ReSwift.Action {
        case mounting(path: String)
        case mountSuccess(path: String)
        case mountFailure(error: LastActionError)
        case unmounting(path: String)
        case unmountSuccess(path: String)
        case unmountFailure(error: LastActionError)
    }

    enum ProcessingType {
        case mount
        case unmount
    }

    enum LastActionError {
        case mount(error: Error)
        case unmount(error: Error)
    }

    var isChanged: Bool
    var type: ProcessingType?
    var path: String?
    var error: LastActionError?

    public static func reducer(action: ReSwift.Action, state: VolumeState?) -> VolumeState {
        var newState = state ?? VolumeState(isChanged: false, type: nil, path: nil, error: nil)

        // 変更済みフラグリセット
        newState.isChanged = false

        // 関心がないアクションは処理しない
        guard let action = action as? VolumeState.Action else {
            return newState
        }

        switch action {
        case let .mounting(path):
            newState.isChanged = true
            newState.type = .mount
            newState.path = path
            newState.error = nil
        case let .mountSuccess(path):
            newState.isChanged = true
            newState.type = nil
            newState.path = path
            newState.error = nil
        case let .mountFailure(error):
            newState.isChanged = true
            newState.type = nil
            newState.path = nil
            newState.error = error
        case let .unmounting(path):
            newState.isChanged = true
            newState.type = .unmount
            newState.path = path
            newState.error = nil
        case .unmountSuccess(_):
            newState.isChanged = true
            newState.type = nil
            newState.path = nil
            newState.error = nil
        case let .unmountFailure(error):
            newState.isChanged = true
            newState.type = nil
//            newState.path = nil // ここを残しておかないと再度アンマウントできなくなる
            newState.error = error
        }

        return newState
    }

}
