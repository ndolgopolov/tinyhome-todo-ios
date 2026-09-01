//
//  TaskListViewModel.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Combine
import Foundation

@MainActor
final class TaskListViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case ready
        case failed
    }

    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var state: State = .loading
    @Published var saveErrorMessage: String?

    private let repository: any TaskRepository
    private let query = TaskQuery.default
    private var pendingWrites: [UUID: Task<Void, Never>] = [:]
    private var newestWriteRequest: [UUID: Int] = [:]

    init(repository: any TaskRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            tasks = try await repository.fetch(query)
            state = .ready
        } catch {
            state = .failed
        }
    }

    func refresh() async {
        if let fetched = try? await repository.fetch(query) {
            tasks = fetched
        }
    }

    func toggleCompletion(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
        let edited = tasks[index]
        scheduleWrite(for: task.id) { [self] in
            replace(id: task.id, with: try await repository.update(edited))
        }
    }

    func delete(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks.remove(at: index)
        scheduleWrite(for: task.id) { [self] in
            try await repository.delete(task.id)
        }
    }

    func save(_ task: TodoTask) {
        let existingIndex = tasks.firstIndex(where: { $0.id == task.id })
        if let existingIndex {
            tasks[existingIndex] = task
        } else {
            tasks.append(task)
        }

        let isNew = existingIndex == nil
        scheduleWrite(for: task.id) { [self] in
            let saved: TodoTask
            if isNew {
                saved = try await repository.create(task)
            } else {
                saved = try await repository.update(task)
            }
            replace(id: task.id, with: saved)

            if let fresh = try? await repository.fetch(query) {
                tasks = fresh
            }
        }
    }

    private func scheduleWrite(for id: UUID, _ write: @escaping () async throws -> Void) {
        let request = (newestWriteRequest[id] ?? 0) + 1
        newestWriteRequest[id] = request
        let previous = pendingWrites[id]

        pendingWrites[id] = Task {
            if let previous {
                await previous.value
            }
            guard newestWriteRequest[id] == request else { return }

            do {
                try await write()
            } catch {
                saveErrorMessage = Self.message(for: error)
                await refresh()
            }

            if newestWriteRequest[id] == request {
                newestWriteRequest[id] = nil
                pendingWrites[id] = nil
            }
        }
    }

    private func replace(id: UUID, with task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index] = task
    }

    private static func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.serverMessage ?? "The server rejected the change"
        }
        if error is URLError {
            return "Can't reach the server. Check your connection"
        }
        return "Something went wrong. Please try again"
    }
}
