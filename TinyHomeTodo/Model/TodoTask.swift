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
    // due date is day-only (no time picker) but stays a full datetime,
    // so adding a time picker later is a UI-only change
    static func endOfDay(for date: Date) -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }
}

extension TodoTask {
    static var samples: [TodoTask] {
        let now = Date.now
        let day: TimeInterval = 86_400
        return [
            TodoTask(taskDescription: "Buy groceries", dueDate: endOfDay(for: now.addingTimeInterval(-day))),
            TodoTask(taskDescription: "Call the landlord about the leak", dueDate: endOfDay(for: now)),
            TodoTask(taskDescription: "Submit expense report", dueDate: endOfDay(for: now.addingTimeInterval(2 * day))),
            TodoTask(taskDescription: "Water the plants"),
            TodoTask(taskDescription: "Renew passport", dueDate: endOfDay(for: now.addingTimeInterval(30 * day))),
            TodoTask(
                taskDescription: "Book dentist appointment",
                isCompleted: true,
                dueDate: endOfDay(for: now.addingTimeInterval(-5 * day))
            ),
            TodoTask(taskDescription: "Read the onboarding doc", isCompleted: true),
        ]
    }
}
