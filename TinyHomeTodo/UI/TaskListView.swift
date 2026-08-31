//
//  TaskListView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

struct TaskListView: View {
    @State private var tasks = TodoTask.samples

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRowView(task: task) {
                    toggleCompletion(task)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        toggleCompletion(task)
                    } label: {
                        Label(
                            task.isCompleted ? "Uncomplete" : "Complete",
                            systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill"
                        )
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        delete(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Tasks")
        }
    }

    private func toggleCompletion(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    private func delete(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
    }
}

#Preview {
    TaskListView()
}
