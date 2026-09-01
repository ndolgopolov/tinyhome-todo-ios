//
//  APITaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation
import OSLog

struct APITaskRepository: TaskRepository {
    let baseURL: String

    private static let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TinyHomeTodo",
        category: "api"
    )

    func fetchTasks() async throws -> [TodoTask] {
        let data = try await perform(makeRequest("GET", path: Endpoint.tasks))
        return try JSONCoding.makeDecoder().decode([TodoTask].self, from: data)
    }

    func create(_ task: TodoTask) async throws -> TodoTask {
        let body = CreateBody(
            taskDescription: task.taskDescription,
            completed: task.isCompleted,
            dueDate: task.dueDate
        )
        return try await send("POST", path: Endpoint.tasks, body: body)
    }

    func update(_ task: TodoTask) async throws -> TodoTask {
        let body = UpdateBody(
            id: task.id,
            taskDescription: task.taskDescription,
            completed: task.isCompleted,
            dueDate: task.dueDate
        )
        return try await send("PUT", path: Endpoint.task(task.id), body: body)
    }

    func delete(_ id: UUID) async throws {
        _ = try await perform(makeRequest("DELETE", path: Endpoint.task(id)))
    }

    private func send(_ method: String, path: String, body: some Encodable) async throws -> TodoTask {
        var request = try makeRequest(method, path: path)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONCoding.makeEncoder().encode(body)

        let data = try await perform(request)
        return try JSONCoding.makeDecoder().decode(TodoTask.self, from: data)
    }

    private func makeRequest(_ method: String, path: String) throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appending(path: path) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        #if DEBUG
        let method = request.httpMethod ?? "?"
        let target = request.url?.absoluteString ?? "?"
        Self.log.debug("-> \(method, privacy: .public) \(target, privacy: .public)")
        if let body = request.httpBody, let text = String(data: body, encoding: .utf8) {
            Self.log.debug("  \(text, privacy: .public)")
        }
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1

        #if DEBUG
        Self.log.debug("<- \(status, privacy: .public) \(method, privacy: .public) \(target, privacy: .public)")
        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            Self.log.debug("  \(text, privacy: .public)")
        }
        #endif

        guard (200..<300).contains(status) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private enum Endpoint {
        static let tasks = "api/tasks"

        static func task(_ id: UUID) -> String {
            "\(tasks)/\(id.uuidString)"
        }
    }
}

private struct CreateBody: Encodable {
    let taskDescription: String
    let completed: Bool
    let dueDate: Date?
}

private struct UpdateBody: Encodable {
    let id: UUID
    let taskDescription: String
    let completed: Bool
    let dueDate: Date?
}
