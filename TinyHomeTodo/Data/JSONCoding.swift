//
//  JSONCoding.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-08-31.
//

import Foundation

enum JSONCoding {
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(decodeISO8601Date)
        return decoder
    }
}

private func decodeISO8601Date(_ decoder: any Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let raw = try container.decode(String.self)
    let trimmed = raw.replacingOccurrences(of: #"\.\d+"#, with: "", options: .regularExpression)
    
    guard let date = ISO8601DateFormatter().date(from: trimmed) else {
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Not an ISO 8601 date: \(raw)"
        )
    }
    return date
}
