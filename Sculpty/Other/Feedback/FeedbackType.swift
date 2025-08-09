//
//  FeedbackType.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import Foundation

enum FeedbackType: String, CaseIterable, Identifiable {
    case bug = "Bug Report"
    case feature = "Feature Request"
    case general = "General Feedback"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var subtitle: String? {
        switch self {
        case .bug:
            return "Please describe the issue in as much detail as possible so it can be resolved as quickly as possible." // swiftlint:disable:this line_length
        default:
            return nil
        }
    }
    
    static let displayOrder: [FeedbackType] = [
        .general, .bug, .feature, .other
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map { $0.rawValue }
}
