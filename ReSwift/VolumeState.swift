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

    var changed: Bool
    private var running: Bool
    var type: ProcessingType?
    var path: String?
    var error: Error?
    var outline: Outline

    enum Action: ReSwift.Action {
        case mounting(path: String)
        case mountSuccess(path: String)
        case mountFailure(error: Error)
        case unmounting(path: String)
        case unmountSuccess(path: String)
        case unmountFailure(error: Error)
    }

    enum Outline {
        case s0 // 初期状態
        case s1 // マウント処理状態
        case s2 // マウント成功状態
        case s3 // マウント失敗状態
        case s4 // アンマウント処理状態
        case s5 // アンマウント成功状態
        case s6 // アンマウント失敗状態
    }

    enum ProcessingType {
        case mount
        case unmount
    }

    public func mounted() -> Bool {
        return !(path == nil)
    }

    public static func reducer(action: ReSwift.Action, state: VolumeState?) -> VolumeState {
        var newState = state ?? VolumeState(changed: false, running: false, type: nil, path: nil, error: nil, outline: .s0)

        // 変更済みフラグリセット
        newState.changed = false

        // 関心がないアクションは処理しない
        guard let action = action as? VolumeState.Action else {
            return newState
        }

        switch action {
        case let .mounting(path):
            newState.changed = true
            newState.running = true
            newState.type = .mount
            newState.path = path
            newState.error = nil
            newState.outline = .s1
        case let .mountSuccess(path):
            newState.changed = true
            newState.running = false
            newState.type = nil
            newState.path = path
            newState.error = nil
            newState.outline = .s2
        case let .mountFailure(error):
            newState.changed = true
            newState.running = false
            newState.type = nil
            newState.path = nil
            newState.error = error
            newState.outline = .s3
        case let .unmounting(path):
            newState.changed = true
            newState.running = true
            newState.type = .unmount
            newState.path = path
            newState.error = nil
            newState.outline = .s4
        case .unmountSuccess(_):
            newState.changed = true
            newState.running = false
            newState.type = nil
            newState.path = nil
            newState.error = nil
            newState.outline = .s5
        case let .unmountFailure(error):
            newState.changed = true
            newState.running = false
            newState.type = nil
//            newState.path = nil // ここを残しておかないと再度アンマウントできなくなる
            newState.error = error
            newState.outline = .s6
        }

        print("Current volume state: \(newState.outline)")

        return newState
    }

}
