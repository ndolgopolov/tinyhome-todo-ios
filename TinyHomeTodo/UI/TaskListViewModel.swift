//
//  TaskListViewModel.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case ready
        case failed
    }

    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var state: State = .loading

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
        tasks[index].isCompleted.toggle()
    }

    func delete(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func save(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
    }
}
