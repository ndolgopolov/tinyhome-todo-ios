//
//  TaskListView.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

struct TaskListView: View {
    private let tasks = TodoTask.samples

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRowView(task: task)
            }
            .listStyle(.plain)
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    TaskListView()
}
