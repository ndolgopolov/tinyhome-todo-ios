//
//  APITaskRepository.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

struct APITaskRepository: TaskRepository {
    let baseURL: String
    
    func fetchTasks() async throws -> [TodoTask] {
        guard let url = URL(string: baseURL)?.appending(path: "api/tasks") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONCoding.makeDecoder().decode([TodoTask].self, from: data)
    }
}
