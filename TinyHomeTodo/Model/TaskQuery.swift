//
//  TaskQuery.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-09-01.
//

import Foundation

struct TaskQuery: Equatable, Sendable {
    var completion: CompletionFilter
    var sortField: SortField
    var sortDirection: SortDirection

    static let `default` = Self(completion: .all, sortField: .dueDate, sortDirection: .ascending)
}

enum CompletionFilter: String {
    case all
    case active
    case completed
}

enum SortField: String {
    case dueDate
    case createdDate
}

enum SortDirection: String {
    case ascending
    case descending
}

extension TaskQuery {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "sort_by", value: sortByValue)]
        if let item = completion.completedQueryItem {
            items.append(item)
        }
        return items
    }

    private var sortByValue: String {
        (sortDirection == .descending ? "-" : "") + sortField.rawValue
    }
}

extension CompletionFilter {
    var completedQueryItem: URLQueryItem? {
        switch self {
        case .all: nil
        case .active: URLQueryItem(name: "completed", value: "false")
        case .completed: URLQueryItem(name: "completed", value: "true")
        }
    }
}
