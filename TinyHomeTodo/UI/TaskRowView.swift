//
//  TaskRowView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-30.
//

import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    var onToggleCompletion: () -> Void = {}

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark as not completed" : "Mark as completed")

            VStack(alignment: .leading, spacing: 3) {
                Text(task.taskDescription)
                    .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)

                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .foregroundStyle(isOverdue ? Color.red : Color.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var isOverdue: Bool {
        guard let dueDate = task.dueDate, !task.isCompleted else { return false }
        return dueDate < .now
    }
}

#Preview {
    List(TodoTask.samples.shuffled()) { task in
        TaskRowView(task: task)
    }
    .listStyle(.plain)
}
