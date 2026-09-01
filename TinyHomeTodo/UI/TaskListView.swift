//
//  TaskListView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var model: TaskListViewModel
    @State private var editor: EditorSheet?

    init(repository: any TaskRepository) {
        _model = StateObject(wrappedValue: TaskListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Tasks")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        filterMenu
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: 76)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        editor = EditorSheet(task: nil)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                    }
                    .padding(20)
                    .accessibilityLabel("New Task")
                }
        }
        .sheet(item: $editor) { sheet in
            TaskEditorView(draft: sheet.task, onSave: model.save)
        }
        .alert(
            "Unable to save your changes",
            isPresented: writeErrorPresented,
            presenting: model.saveErrorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
        .task(id: model.query) {
            await model.load()
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Filter") {
                Picker("Filter", selection: $model.completion) {
                    Text("All").tag(CompletionFilter.all)
                    Text("Not Completed").tag(CompletionFilter.active)
                    Text("Completed").tag(CompletionFilter.completed)
                }
                .pickerStyle(.inline)
            }

            Section("Sort By") {
                Picker("Sort By", selection: $model.sortField) {
                    Text("Due Date").tag(SortField.dueDate)
                    Text("Creation Date").tag(SortField.createdDate)
                }
                .pickerStyle(.inline)
            }

            Section("Order") {
                Picker("Order", selection: $model.sortDirection) {
                    Text("Ascending").tag(SortDirection.ascending)
                    Text("Descending").tag(SortDirection.descending)
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label("Filter and sort", systemImage: menuIcon)
        }
    }

    private var menuIcon: String {
        model.query == .default
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
    }

    private var writeErrorPresented: Binding<Bool> {
        Binding(
            get: { model.saveErrorMessage != nil },
            set: { presented in
                if !presented {
                    model.saveErrorMessage = nil
                }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            failure
        case .ready:
            if model.tasks.isEmpty {
                emptyState
            } else {
                list
            }
        }
    }

    private var list: some View {
        List(model.tasks) { task in
            row(for: task)
        }
        .listStyle(.plain)
        .refreshable {
            await model.refresh()
        }
    }
    
    // ContentUnavailableView is not available on iOS < 17
    private var emptyState: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text(emptyTitle)
                        .font(.headline)
                    if let emptySubtitle {
                        Text(emptySubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .refreshable {
                await model.refresh()
            }
        }
    }

    private var emptyTitle: String {
        model.completion == .all ? "No tasks yet" : "No matching tasks"
    }

    private var emptySubtitle: String? {
        model.completion == .all ? "Tap + to add one." : nil
    }

    // ContentUnavailableView is not available on iOS < 17
    private var failure: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("Couldn't load your tasks")
                .font(.headline)
            Button("Try Again") {
                Task { await model.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    @ViewBuilder
    private func row(for task: TodoTask) -> some View {
        Button {
            editor = EditorSheet(task: task)
        } label: {
            TaskRowView(task: task) {
                model.toggleCompletion(task)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading) {
            Button {
                model.toggleCompletion(task)
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
                model.delete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private extension TaskListView {
    struct EditorSheet: Identifiable {
        let id = UUID()
        let task: TodoTask?
    }
}

#Preview("Loaded") {
    TaskListView(repository: SampleTaskRepository())
}

#Preview("Empty") {
    TaskListView(repository: SampleTaskRepository(empty: true))
}

#Preview("Failed") {
    TaskListView(repository: SampleTaskRepository(fails: true))
}
