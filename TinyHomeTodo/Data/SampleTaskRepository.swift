//
//  SampleTaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation
/// Mock-repository for preview and testing purposes
struct SampleTaskRepository: TaskRepository {
    /// If true, the `fetchTasks()` method will throw an error
    var fails = false
    /// If true, the `fetchTasks()` method will return an empty array
    var empty = false
    
    func fetchTasks() async throws -> [TodoTask] {
        try await Task.sleep(for: .milliseconds(120))
        
        if empty {
            return []
        }
        
        if fails {
            throw URLError(.notConnectedToInternet)
        }
        
        return TodoTask.samples
    }
}
