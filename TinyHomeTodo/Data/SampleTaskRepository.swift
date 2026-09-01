//
//  SampleTaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

/// Mock-repository for preview and testing purposes
struct SampleTaskRepository: TaskRepository {
    /// If true, `fetch(_:)` throws an error
    var fails = false
    /// If true, `fetch(_:)` returns an empty array
    var empty = false

    func fetch(_ query: TaskQuery) async throws -> [TodoTask] {
        try await Task.sleep(for: .milliseconds(120))

        if fails {
            throw URLError(.notConnectedToInternet)
        }

        if empty {
            return []
        }

        return Self.sorted(Self.filtered(TodoTask.samples, by: query), by: query)
    }

    func create(_ task: TodoTask) async throws -> TodoTask {
        try await Task.sleep(for: .milliseconds(120))
        var created = task
        created.id = UUID()
        created.createdDate = .now
        return created
    }

    func update(_ task: TodoTask) async throws -> TodoTask {
        try await Task.sleep(for: .milliseconds(120))
        return task
    }

    func delete(_: UUID) async throws {
        try await Task.sleep(for: .milliseconds(120))
    }

    private static func filtered(_ tasks: [TodoTask], by query: TaskQuery) -> [TodoTask] {
        switch query.completion {
        case .all: tasks
        case .active: tasks.filter { !$0.isCompleted }
        case .completed: tasks.filter(\.isCompleted)
        }
    }

    private static func sorted(_ tasks: [TodoTask], by query: TaskQuery) -> [TodoTask] {
        tasks.sorted { lhs, rhs in
            switch (sortKey(lhs, field: query.sortField), sortKey(rhs, field: query.sortField)) {
            case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
                return query.sortDirection == .ascending ? lhsDate < rhsDate : lhsDate > rhsDate
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default:
                return lhs.id.uuidString < rhs.id.uuidString
            }
        }
    }

    private static func sortKey(_ task: TodoTask, field: SortField) -> Date? {
        switch field {
        case .dueDate: task.dueDate
        case .createdDate: task.createdDate
        }
    }
}
