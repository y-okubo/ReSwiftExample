//
//  ReSwiftExampleTests.swift
//  ReSwiftExampleTests
//
//  Created by Yuki Okubo on 2/7/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import XCTest
import ReSwift

class ReSwiftExampleTests: XCTestCase {

    class StabSubscriber: StoreSubscriber {
        var delegate: ((StoreSubscriberStateType) -> Void)?
        func newState(state: AppState) {
            guard let delegate = self.delegate else { return }
            delegate(state)
        }
    }

    let expect = XCTestExpectation(description: "")
    let store = AppStore.shared.store
    let stab = StabSubscriber()

    override func setUp() {
        self.store.subscribe(self.stab)
    }

    override func tearDown() {
        self.store.unsubscribe(self.stab)
    }

    func testLoginSuccess() {
        self.stab.delegate = { state in
            guard let authenticationState = state.authenticationState else { return }
            if authenticationState.isChanged && !authenticationState.isProcessing {
                self.expect.fulfill()
                XCTAssertNotNil(authenticationState.token)
            }
        }

        store.dispatch(ActionCreator.executeLogin(username: "tester", password: "debug"))
        wait(for: [self.expect], timeout: 10.0)
    }

    func testLoginFailure() {
        self.stab.delegate = { state in
            guard let authenticationState = state.authenticationState else { return }
            if authenticationState.isChanged && !authenticationState.isProcessing {
                self.expect.fulfill()
                XCTAssertNil(authenticationState.token)
            }
        }

        store.dispatch(ActionCreator.executeLogin(username: "tester", password: "faild"))
        wait(for: [self.expect], timeout: 10.0)
    }

    func testMountSuccess() {
        self.stab.delegate = { state in
            guard let authenticationState = state.authenticationState, let _ = authenticationState.token else { return }
            guard let volumeState = state.volumeState, let _ = volumeState.type else { return }
            self.expect.fulfill()
            if let path = volumeState.path {
                XCTAssert(path != "")
            }
        }

        store.dispatch(ActionCreator.executeLogin(username: "tester", password: "debug"))
        wait(for: [self.expect], timeout: 10.0)
    }

}
