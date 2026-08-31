//
//  TodoTask.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-30.
//

import Foundation

/// A single to-do item
struct TodoTask: Identifiable {
    let id = UUID()
    var taskDescription: String
    var isCompleted = false
    var dueDate: Date?
}

extension TodoTask {
    static var samples: [TodoTask] {
        let now = Date.now
        return [
            TodoTask(taskDescription: "Buy groceries", dueDate: now.addingTimeInterval(-3_600)),
            TodoTask(taskDescription: "Call the landlord about the leak", dueDate: now.addingTimeInterval(7_200)),
            TodoTask(taskDescription: "Submit expense report", dueDate: now.addingTimeInterval(172_800)),
            TodoTask(taskDescription: "Water the plants"),
            TodoTask(taskDescription: "Renew passport", dueDate: now.addingTimeInterval(2_592_000)),
            TodoTask(
                taskDescription: "Book dentist appointment",
                isCompleted: true,
                dueDate: now.addingTimeInterval(-432_000)
            ),
            TodoTask(taskDescription: "Read the onboarding doc", isCompleted: true),
        ]
    }
}
