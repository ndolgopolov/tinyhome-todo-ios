//
//  TinyHomeTodoApp.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-28.
//

import SwiftUI

@main
struct TinyHomeTodoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(.tint)
            Text("TinyHome Todo")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
