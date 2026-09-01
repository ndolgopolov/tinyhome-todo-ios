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

    init(repository: any TaskRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            tasks = try await repository.fetchTasks()
            state = .ready
        } catch {
            state = .failed
        }
    }

    func refresh() async {
        if let fetched = try? await repository.fetchTasks() {
            tasks = fetched
        }
    }

    func toggleCompletion(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        var edited = tasks[index]
        edited.isCompleted.toggle()
        sendUpdate(edited)
    }

    func delete(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let removed = tasks.remove(at: index)
        Task {
            do {
                try await repository.delete(task.id)
            } catch {
                restore(removed, at: index)
                saveErrorMessage = Self.message(for: error)
            }
        }
    }

    func save(_ task: TodoTask) {
        let snapshot = tasks
        let existingIndex = tasks.firstIndex(where: { $0.id == task.id })

        if let existingIndex {
            tasks[existingIndex] = task
        } else {
            tasks.append(task)
        }

        Task {
            do {
                let saved: TodoTask
                if existingIndex == nil {
                    saved = try await repository.create(task)
                } else {
                    saved = try await repository.update(task)
                }
                replace(id: task.id, with: saved)

                if let fresh = try? await repository.fetchTasks() {
                    tasks = fresh
                }
            } catch {
                tasks = snapshot
                saveErrorMessage = Self.message(for: error)
            }
        }
    }

    private func sendUpdate(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let original = tasks[index]
        tasks[index] = task
        Task {
            do {
                replace(id: task.id, with: try await repository.update(task))
            } catch {
                replace(id: task.id, with: original)
                saveErrorMessage = Self.message(for: error)
            }
        }
    }

    private func replace(id: UUID, with task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index] = task
    }

    private func restore(_ task: TodoTask, at index: Int) {
        tasks.insert(task, at: min(index, tasks.count))
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
