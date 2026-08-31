//
//  TinyHomeTodoApp.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

@main
struct TinyHomeTodoApp: App {
    // Set `.preview` to run without backend
    private let environment = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            TaskListView(repository: environment.repository)
        }
    }
}
