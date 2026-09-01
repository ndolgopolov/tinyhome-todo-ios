//
//  TaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

protocol TaskRepository: Sendable {
    func fetchTasks() async throws -> [TodoTask]
    func create(_ task: TodoTask) async throws -> TodoTask
    func update(_ task: TodoTask) async throws -> TodoTask
    func delete(_ id: UUID) async throws
}
