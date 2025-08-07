//
//  ArrayExtensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict: [Element: Bool] = [:]

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array {
    func search<T: StringProtocol>(
        _ query: T,
        by keyPath: KeyPath<Element, String>
    ) -> [Element] {
        guard !String(query).normalized().isEmpty else { return self }
        
        let normalizedQuery = String(query).normalized()
        
        return self.filter { element in
            element[keyPath: keyPath].normalized().contains(normalizedQuery)
        }
    }
}
