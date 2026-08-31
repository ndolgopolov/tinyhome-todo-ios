//
//  TaskEditorView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import SwiftUI

/// Add or edit a task
struct TaskEditorView: View {
    let taskDraft: TodoTask?
    let onSave: (TodoTask) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var task: TodoTask

    init(draft: TodoTask?, onSave: @escaping (TodoTask) -> Void) {
        self.taskDraft = draft
        self.onSave = onSave
        _task = State(initialValue: draft ?? TodoTask(taskDescription: ""))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Description", text: $task.taskDescription, axis: .vertical)
                }

                Section {
                    Toggle("Due date", isOn: dateEnabled)
                    if task.dueDate != nil {
                        DatePicker("", selection: dueDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                }
            }
            .animation(.default, value: task.dueDate)
            .navigationTitle(taskDraft == nil ? "New Task" : "Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton
                        .disabled(!isValid)
                }
            }
        }
    }

    // iOS 26+ renders these as system confirm/cancel toolbar buttons
    @ViewBuilder
    private var confirmButton: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm) { commit() }
        } else {
            Button(taskDraft == nil ? "Add" : "Done") { commit() }
                .fontWeight(.semibold)
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel) { dismiss() }
        } else {
            Button("Cancel") { dismiss() }
        }
    }

    private var dueDate: Binding<Date> {
        Binding(
            get: { task.dueDate ?? .now },
            set: { task.dueDate = TodoTask.endOfDay(for: $0) }
        )
    }

    private var dateEnabled: Binding<Bool> {
        Binding(get: { task.dueDate != nil }, set: { isOn in
            task.dueDate = isOn ? TodoTask.endOfDay(for: task.dueDate ?? .now) : nil
        })
    }

    private var isValid: Bool {
        !task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func commit() {
        task.taskDescription = task.taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(task)
        dismiss()
    }
}

#Preview("Add") {
    TaskEditorView(draft: nil, onSave: { _ in () })
}

#Preview("Edit") {
    TaskEditorView(
        draft: TodoTask(taskDescription: "Buy groceries", dueDate: TodoTask.endOfDay(for: .now)),
        onSave: { _ in () }
    )
}
