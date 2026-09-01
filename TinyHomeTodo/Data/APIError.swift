//
//  APIError.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-09-01.
//

import Foundation

struct APIError: LocalizedError {
    let statusCode: Int
    let serverMessage: String?

    var errorDescription: String? {
        serverMessage ?? "The server returned status \(statusCode)."
    }
}
