//
//  Error.swift
//  ReSwiftExample
//
//  Created by Yuki Okubo on 2/4/19.
//  Copyright © 2019 Nekojarashi Inc. All rights reserved.
//

import Foundation

enum ServerError: Error {
    case notFound
    case unknown
}

enum MountError: Error {
    case unauthorized
    case notMounted
    case unknown
}
