//
//  Binding+Presence.swift
//  TinyHomeTodo
//
//  Created by Nikolay Dolgopolov on 2026-09-01.
//

import SwiftUI

extension Binding where Value == Bool {
    init<Wrapped>(presence value: Binding<Wrapped?>) {
        self.init(
            get: { value.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    value.wrappedValue = nil
                }
            }
        )
    }
}
