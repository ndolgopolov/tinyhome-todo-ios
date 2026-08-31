//
//  SampleTaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

struct SampleTaskRepository: TaskRepository {
    func fetchTasks() async throws -> [TodoTask] {
        try await Task.sleep(for: .milliseconds(120))
        return TodoTask.samples
    }
}
