//
//  TinyHomeTodoApp.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

@main
struct TinyHomeTodoApp: App {
    private let environment = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            TaskListView(repository: environment.repository)
        }
    }
}
