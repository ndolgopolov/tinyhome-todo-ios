//
//  AppEnvironment.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

struct AppEnvironment: Sendable {
    let repository: any TaskRepository

    static let live = Self(repository: APITaskRepository(baseURL: "http://localhost:8090"))
    static let preview = Self(repository: SampleTaskRepository())
}
