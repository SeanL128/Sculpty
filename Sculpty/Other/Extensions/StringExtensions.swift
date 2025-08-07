//
//  StringExtensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import Foundation

extension String {
    func filteredNumeric() -> String {
        let filtered = self.filter { "0123456789.".contains($0) }
        let components = filtered.split(separator: ".")
        let string = components.count > 2 ? "\(components[0]).\(components[1])" : filtered
        return string.count > 1 ? string.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : string
    }
    
    func filteredNumericWithoutDecimalPoint() -> String {
        let filtered = self.filter { "0123456789".contains($0) }
        return filtered.count > 1 ? filtered.replacing(/^([+-])?0+/, with: {$0.output.1 ?? ""}) : filtered
    }
    
    func normalized() -> String {
        return self
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }
}
