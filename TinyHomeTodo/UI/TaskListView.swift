//
//  TaskListView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

struct TaskListView: View {
    @State private var tasks = TodoTask.samples
    @State private var editor: EditorSheet?

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                row(for: task)
            }
            .listStyle(.plain)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button {
                        editor = EditorSheet(task: nil)
                    } label: {
                        Label("New Task", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(item: $editor) { sheet in
            TaskEditorView(draft: sheet.task, onSave: save)
        }
    }

    @ViewBuilder
    private func row(for task: TodoTask) -> some View {
        Button {
            editor = EditorSheet(task: task)
        } label: {
            TaskRowView(task: task) {
                toggleCompletion(task)
            }
        }
        .buttonStyle(.plain)
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

    private func toggleCompletion(_ task: TodoTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    private func delete(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
    }

    private func save(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
    }
}

private extension TaskListView {
    struct EditorSheet: Identifiable {
        let id = UUID()
        let task: TodoTask?
    }
}

#Preview {
    TaskListView()
}
